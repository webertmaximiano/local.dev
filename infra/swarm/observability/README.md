# Monitoramento local com Prometheus e Grafana (Swarm)

Esta stack opcional coleta métricas do Traefik do laboratório e apresenta dashboards no Grafana. Ela não é iniciada por `make traefik-up` nem por `make portainer-up`. Use-a enquanto estiver estudando ou investigando; desligue-a quando terminar para liberar CPU e memória.

## O que sobe

- **Prometheus** consulta métricas do Traefik pela rede overlay interna `monitoring`, mantém até 24 horas e limita o TSDB a 512 MB.
- **Grafana** consulta Prometheus pela rede interna e mantém dashboards e configurações em volume Docker.
- Os dois serviços têm limites de CPU/memória, rotação de logs e não publicam portas diretamente no host.
- Só Traefik e Prometheus são alvos nesta etapa. Node Exporter, Alertmanager, agregação de logs e tracing não estão instalados.
- Os limites dos dois serviços somam até 1 GiB de memória; a stack é opcional para que esse consumo não fique ativo enquanto você trabalha em outras aplicações.

Em Swarm, Prometheus encontra as tasks com DNS `tasks.<stack>_<serviço>`. A configuração usa `tasks.traefik_traefik` e a porta interna 8082. Isso coleta cada réplica como um target separado sem montar o socket Docker dentro do Prometheus. A descoberta é nativa do DNS de serviços do Swarm; veja a [documentação de redes e descoberta do Docker](https://docs.docker.com/engine/swarm/networking/) e a [configuração DNS do Prometheus](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#dns_sd_config).

As labels Prometheus `target_environment`, `target_orchestrator`, `target_stack` e `target_service` são adicionadas na configuração de scrape. O prefixo `target_` diferencia metadados do alvo das labels nativas das métricas (como `service` do Traefik), evitando colisões. Use esse conjunto para filtrar e agrupar consultas, por exemplo:

```promql
sum by (entrypoint) (rate(traefik_entrypoint_requests_total{target_stack="traefik"}[5m]))
```

Labels de roteamento `traefik.*` em `deploy.labels` configuram o proxy; elas não ativam sozinhas a coleta Prometheus. Para monitorar outra aplicação, conecte-a a `monitoring`, exponha um endpoint interno de métricas e adicione um job DNS e as mesmas quatro labels `target_*` em `prometheus/prometheus.yml`. Não publique a porta `/metrics` no host. Evite labels com URL completa, IDs de usuário, e-mail ou outros valores variáveis: cada valor novo aumenta o número de séries e pode expor dados pessoais.

Exemplo didático para uma stack `catalog`, serviço `api`, com endpoint `/metrics` na porta interna 8080:

```yaml
# Trecho de prometheus/prometheus.yml
- job_name: catalog-api
  metrics_path: /metrics
  dns_sd_configs:
    - names: [tasks.catalog_api]
      type: A
      port: 8080
  relabel_configs:
    - target_label: target_environment
      replacement: local
    - target_label: target_orchestrator
      replacement: swarm
    - target_label: target_stack
      replacement: catalog
    - target_label: target_service
      replacement: api
```

O serviço da aplicação também precisa participar da rede externa `monitoring`. Ajuste nomes e porta ao seu serviço e valide o target como `UP` antes de criar dashboards.

## Requisitos e primeiro acesso

1. Siga o guia da infraestrutura em [`../README.md`](../README.md), gere o certificado com `make tls-setup` e inicie o Traefik com `make traefik-up`.
2. Cadastre os hosts locais adicionais em `/etc/hosts`:

   ```text
   127.0.0.1 prometheus.local.dev
   127.0.0.1 grafana.local.dev
   ```

3. Na raiz do repositório, execute:

   ```bash
   make monitoring-up
   ```

Na primeira execução, o Make solicita uma senha para o administrador Grafana e cria um Docker Secret. A senha não é escrita no repositório nem passada na linha de comando. O Prometheus é protegido pelo middleware BasicAuth já usado no dashboard Traefik; o Grafana usa seu próprio login.

Os domínios locais são `https://prometheus.local.dev` e `https://grafana.local.dev`. Use `admin` e a senha escolhida para o Grafana. Para Prometheus, use o login/senha BasicAuth do Traefik.

## Verificar e aprender

```bash
make status
docker service ps observability_prometheus
docker service ps observability_grafana
make logs-prometheus
make logs-grafana
```

Em Prometheus, abra **Status → Targets** e confirme que `traefik` está `UP`. Em **Alerts**, veja as regras `TraefikMetricsTargetDown` e `TraefikHigh5xxRate`. Elas podem aparecer como `pending` ou `firing`, mas não enviam mensagens: esta stack não instala Alertmanager nem configura destino de notificação. Defina quem recebe cada alerta, o canal, os limites e a janela de avaliação antes de tratar uma regra como operacional.

No Grafana, confirme a fonte Prometheus em **Connections → Data sources**. Importe o [Traefik Official Standalone Dashboard (ID 17346)](https://grafana.com/grafana/dashboards/17346-traefik-official-standalone-dashboard/) e selecione o datasource `Prometheus`. Esse dashboard usa métricas do Traefik standalone e pode não representar labels específicos de cada aplicação.

Métricas mostram tendências e agregados. Logs ajudam a explicar eventos individuais:

```bash
docker service logs --since 15m traefik_traefik
docker service logs --since 15m observability_prometheus
docker service logs --since 15m observability_grafana
```

Use `docker service ps --no-trunc <serviço>` e `docker service inspect <serviço>` para investigar estado de tasks e configuração. Os serviços enviam logs ao driver `json-file`, com rotação limitada a três arquivos de 10 MB. A retenção reduz o risco de logs locais ocuparem o disco, mas logs que giraram não podem ser recuperados.

Como triagem inicial, respostas 4xx costumam apontar para a requisição ou autenticação do cliente; 5xx indicam falha no proxy, aplicação ou serviço upstream. O código HTTP orienta a investigação, mas não identifica sozinho a causa. Correlacione horário, rota, métrica e logs, sem copiar tokens, cookies ou dados pessoais para consultas ou labels.

## Senha e persistência

O Docker Secret entrega a senha inicial ao Grafana como arquivo (`GF_SECURITY_ADMIN_PASSWORD__FILE`). O Grafana grava a conta no banco local do volume; atualizar o Secret sozinho **não troca** a senha já cadastrada. Troque a senha pela interface de administração do Grafana. Guarde a senha atualizada no cofre usado para administrar o ambiente e mantenha o Docker Secret em sincronia se pretende reconstruir o serviço depois de perder o volume.

Para sincronizar o Secret de recuperação após alterar a senha pela UI, execute `make monitoring-secret-rotate` e informe a senha nova. O alvo atualiza a referência da stack, mas não muda a senha armazenada pelo Grafana. Depois de confirmar que a stack está saudável e o login funciona, remova Secrets antigos que não estejam mais em uso; nunca remova o Secret referenciado pelo serviço.

`make monitoring-down` remove os serviços, mas preserva os volumes e o histórico. Por isso, desligar a stack economiza CPU e memória, mas não apaga os dados do disco. Os volumes pertencem ao nó onde os serviços gravaram os dados; esta configuração local não fornece replicação nem alta disponibilidade. Faça backup antes de qualquer limpeza manual.

Docker Configs são imutáveis. Se editar `prometheus/prometheus.yml`, `prometheus/alerts.yml` ou `grafana/datasources/prometheus.yml`, aplique a mudança com `make monitoring-down` seguido por `make monitoring-up`. A stack e seus Configs serão recriados; os volumes de dados serão mantidos.

As versões das imagens estão fixadas no manifesto. Ao atualizá-las, revise as notas da versão, altere as tags explicitamente e valide a configuração antes de publicar a stack.

Esta configuração e a rede overlay `monitoring` são para laboratório local. Métricas podem revelar nomes de serviços, rotas e padrões de tráfego. Não exponha a porta 8082, os dashboards ou os endpoints de métricas à Internet; adapte controles de acesso, segmentação e proteção do tráfego overlay antes de usar entre VPS.

## Desligar

```bash
make monitoring-down
```

Isso remove somente a stack `observability`; Traefik, Portainer, outras stacks e volumes nomeados ficam intactos. Para voltar a monitorar, execute `make monitoring-up`.
