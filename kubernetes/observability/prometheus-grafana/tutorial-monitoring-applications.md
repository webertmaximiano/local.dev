# Primeiros passos com métricas de aplicações

Este exercício parte do laboratório [`tutorial-prometheus-grafana.md`](tutorial-prometheus-grafana.md), que instala Prometheus e Grafana e configura o scrape do Traefik. Faça esse laboratório antes deste. Ele demonstra **métricas**; não instala coleta centralizada de logs nem rastreamento distribuído.

## Como as peças se conectam

1. Uma aplicação expõe métricas em um endpoint HTTP, normalmente `/metrics`.
2. Prometheus acessa esse endpoint periodicamente (modelo *pull*) e armazena os valores como séries temporais.
3. Grafana consulta Prometheus e transforma resultados em tabelas e gráficos.

O Prometheus não descobre automaticamente toda aplicação. O endpoint precisa ser alcançável e ter uma configuração de scrape. Neste laboratório, `prometheus-values.yaml` procura Pods do Traefik no namespace `default` e mantém apenas a porta de container chamada `metrics`. A porta é interna ao Pod; o Traefik Helm chart não a publica pelo LoadBalancer.

## Confirmar o target do Traefik

Abra `https://prometheus.local.dev/targets`, autentique-se e procure o job `traefik`. O estado **UP** confirma que a última coleta funcionou. Se estiver **DOWN**, abra o detalhe do target e confira o erro; depois verifique o Pod e os logs do Traefik:

```bash
kubectl get pods -n default
kubectl logs deploy/traefik -n default --tail=100
```

Se o Deployment tiver outro nome, encontre-o com `kubectl get deployments -n default`. No Prometheus, `up{job="traefik"}` retorna `1` para um target acessível e `0` quando a coleta falha.

## Fazer consultas PromQL

Abra `https://prometheus.local.dev/graph` ou o Grafana em `https://grafana.local.dev` → **Explore**, e selecione a fonte `Prometheus`.

Total de solicitações por segundo, agregado por entrypoint:

```promql
sum by (entrypoint) (rate(traefik_entrypoint_requests_total[5m]))
```

Solicitações 5xx por segundo:

```promql
sum(rate(traefik_entrypoint_requests_total{code=~"5.."}[5m]))
```

Proporção de respostas 5xx em relação a todas as respostas, nos últimos cinco minutos:

```promql
sum(rate(traefik_entrypoint_requests_total{code=~"5.."}[5m]))
/
sum(rate(traefik_entrypoint_requests_total[5m]))
```

Essa proporção fica vazia se não houver tráfego no período. Em produção, trate divisão por zero e defina o indicador com o contexto do serviço. Métricas disponíveis dependem das opções de métricas e da versão do Traefik; confirme nomes e labels no autocompletar do Prometheus antes de reutilizar consultas.

## Entender o custo dos labels

Cada combinação diferente de labels cria uma série temporal. Labels controlados pelo usuário, como URL completa, identificador de pessoa, e-mail ou ID de pedido, podem criar muitas séries e expor dados pessoais. Prefira labels de baixa cardinalidade, como método HTTP, código de resposta, nome estável do serviço e ambiente. Não inclua credenciais nem dados pessoais em métricas.

## Importar um dashboard

No Grafana, abra **Dashboards → New → Import**, informe o ID `17347` e associe o datasource `Prometheus`. Esse é o [Traefik Official Kubernetes Dashboard](https://grafana.com/grafana/dashboards/17347-traefik-official-kubernetes-dashboard/). Ele é específico para Traefik em Kubernetes; dashboards destinados ao modo standalone/Swarm podem não ter os labels que este chart coleta.

Dashboards importados da comunidade são código/configuração de terceiros: confira a origem e as consultas antes de usar em ambientes importantes. Para aprender, abra os painéis e identifique a métrica e a agregação usadas.

## Métricas, logs e traces têm papéis diferentes

- **Métricas** mostram tendências agregadas: volume de requisições, taxa de erro e latência.
- **Logs** registram eventos individuais. Neste cluster, consulte `kubectl logs <pod> -n <namespace>`; não existe Loki nem outro agregador configurado.
- **Traces** acompanham uma requisição através de vários serviços. OpenTelemetry/Jaeger/Tempo não fazem parte deste laboratório.

## Alertas

O exemplo desativa Alertmanager para economizar recursos. Consultar uma série no Grafana não cria um alerta nem entrega notificações. Para um alerta operacional, defina uma regra clara, um período que evite oscilações, quem recebe a notificação e como validar o destino. A instalação de regras, Alertmanager e um canal de notificação fica para uma etapa posterior.

## Aplicações próprias

Para instrumentar um serviço, escolha uma biblioteca compatível com a linguagem, exponha métricas úteis sem dados pessoais e disponibilize o endpoint só na rede interna do cluster. Depois configure Prometheus para encontrar esse serviço (por exemplo, via annotations/labels e descoberta Kubernetes) e confirme o target como **UP** antes de construir um dashboard.
