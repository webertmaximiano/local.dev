# Monitoramento local com Prometheus e Grafana (Kubernetes)

Este laboratório opcional ensina a coletar e consultar **métricas** do Traefik no cluster Kubernetes. Prometheus coleta e armazena séries temporais; Grafana consulta essas séries e apresenta gráficos. A configuração não instala uma solução centralizada de logs, não monitora o host e não envia notificações de alerta.

Esta é a trilha Kubernetes. Para o ambiente local padrão com Swarm, consulte [`infra/swarm/README.md`](../../../infra/swarm/README.md). O Traefik Kubernetes e o Traefik Swarm disputam as portas 80/443: pare um antes de iniciar o outro.

## Pré-requisitos

- Um cluster Kubernetes local iniciado e o contexto correto selecionado (`kubectl config current-context`).
- Traefik instalado no cluster com o tutorial [`../../networking/traefik/tutorial-kubernetes-traefik.md`](../../networking/traefik/tutorial-kubernetes-traefik.md) concluído.
- Helm 3, kubectl e curl.
- Os nomes `traefik.local.dev`, `prometheus.local.dev` e `grafana.local.dev` resolvendo para `127.0.0.1` no arquivo hosts.
- O certificado local criado pelo tutorial do Traefik em `kubernetes/networking/traefik/certs/local.dev/`. Não versione certificados ou chaves privadas.

Antes de começar, confirme o contexto do cluster. Os comandos a seguir criam recursos e Secrets nesse contexto.

```bash
kubectl config current-context
kubectl get pods -n default
```

> O Traefik Swarm normalmente ocupa as portas 80/443. Se o cluster Kubernetes não conseguir publicar essas portas, pare o Traefik Swarm antes de continuar.

## 1. Criar namespaces e Secrets TLS

No Kubernetes, um Secret só pode ser usado por recursos do mesmo namespace. O Secret TLS criado em `default` para o dashboard do Traefik não é visível nos namespaces de Prometheus e Grafana. Vamos criar uma cópia local do mesmo certificado em cada namespace:

```bash
kubectl create namespace monitoring-prometheus --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring-grafana --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret tls local-dev-tls \
  --cert=kubernetes/networking/traefik/certs/local.dev/local.dev.crt \
  --key=kubernetes/networking/traefik/certs/local.dev/local.dev.key \
  -n monitoring-prometheus --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret tls local-dev-tls \
  --cert=kubernetes/networking/traefik/certs/local.dev/local.dev.crt \
  --key=kubernetes/networking/traefik/certs/local.dev/local.dev.key \
  -n monitoring-grafana --dry-run=client -o yaml | kubectl apply -f -
```

O padrão `create --dry-run=client -o yaml | apply` permite repetir os comandos e atualizar o Secret se o certificado for renovado. O conteúdo dos Secrets não deve ser commitado.

## 2. Instalar o Prometheus

O arquivo [`prometheus-values.yaml`](prometheus-values.yaml) é a configuração única usada pelo tutorial. Ele reduz o consumo local desativando componentes auxiliares e as coletas Kubernetes padrão, mantendo apenas o próprio Prometheus e o Traefik. Também limita a retenção a 24 horas e usa armazenamento efêmero. Ao remover ou recriar o Pod do Prometheus, as métricas coletadas são descartadas. Isso é adequado ao laboratório, mas não a um serviço de monitoramento que precise preservar histórico.

Adicione o repositório Helm e instale ou atualize a release:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace monitoring-prometheus --create-namespace \
  -f kubernetes/observability/prometheus-grafana/prometheus-values.yaml \
  --wait
```

O comando `upgrade --install` pode ser repetido: instala a release se ainda não existir e atualiza sua configuração se já existir.

## 3. Criar o Secret administrativo do Grafana

O valor da senha não deve aparecer no histórico do shell nem em um arquivo versionado. Crie um arquivo temporário com permissões restritas, abra-o no editor e escreva somente a senha. O arquivo será removido ao sair do shell atual:

```bash
password_file="$(mktemp)"
chmod 600 "$password_file"
trap 'rm -f "$password_file"' EXIT
${EDITOR:-vi} "$password_file"
```

Salve e feche o editor. Em seguida, crie ou atualize o Secret sem imprimir a senha:

```bash
kubectl create secret generic grafana-admin-secret \
  --from-literal=admin-user=admin \
  --from-file=admin-password="$password_file" \
  -n monitoring-grafana --dry-run=client -o yaml | kubectl apply -f -
```

Mantenha o Secret no cluster e nunca o copie para o Git. A configuração do chart referencia esse Secret e não contém a senha.

## 4. Instalar o Grafana

O arquivo [`grafana-values.yaml`](grafana-values.yaml) configura uma fonte de dados Prometheus interna ao cluster. Essa comunicação usa o Service Kubernetes e não passa pelo Ingress público. O armazenamento do Grafana também é efêmero: dashboards importados manualmente podem se perder se o Pod for recriado. Este comportamento é intencional no laboratório econômico.

```bash
helm repo add grafana-community https://grafana-community.github.io/helm-charts
helm repo update
helm upgrade --install grafana grafana-community/grafana \
  --namespace monitoring-grafana --create-namespace \
  -f kubernetes/observability/prometheus-grafana/grafana-values.yaml \
  --wait
```

## 5. Verificar instalação e coleta

Confira os Pods e os Ingresses:

```bash
kubectl get pods,ingress -n monitoring-prometheus
kubectl get pods,ingress -n monitoring-grafana
```

Abra `https://prometheus.local.dev/targets` e confirme que o target `traefik` aparece como **UP**. O endereço `/targets` mostra se Prometheus consegue alcançar o endpoint de métricas; **DOWN** indica um problema de descoberta, rede ou configuração do endpoint.

O Ingress do Prometheus reutiliza o middleware de autenticação básica do dashboard Traefik. Teste sem credenciais; a resposta esperada é `401`:

```bash
curl -sS -o /dev/null -w '%{http_code}\n' https://prometheus.local.dev/
```

Com credenciais, curl solicita a senha interativamente. A resposta esperada é `200`:

```bash
curl -sS -o /dev/null -w '%{http_code}\n' --user admin https://prometheus.local.dev/
```

Não use `-k` para ignorar a validação TLS. Se o navegador ou curl não confiar no certificado local, corrija a instalação da CA seguindo o tutorial do Traefik.

Abra `https://grafana.local.dev`, entre com usuário `admin` e a senha escolhida, e confirme em **Connections → Data sources** que `Prometheus` está disponível. Em **Explore**, selecione essa fonte de dados e consulte:

```promql
up{job="traefik"}
```

O valor `1` indica que a última coleta foi bem-sucedida. `0` indica falha na coleta.

## 6. Consultar e visualizar métricas

Prometheus expõe o próprio painel de consultas. Em `https://prometheus.local.dev/graph`, experimente:

```promql
sum(rate(traefik_entrypoint_requests_total[5m]))
```

Isso estima requisições por segundo por entrypoint nos últimos cinco minutos. Contadores acumulam ao longo do tempo; `rate` calcula sua velocidade de crescimento. Para contar respostas HTTP 5xx por segundo:

```promql
sum(rate(traefik_entrypoint_requests_total{code=~"5.."}[5m]))
```

Os nomes e labels disponíveis podem variar conforme versão e configuração do Traefik. Consulte o endpoint **Status → Targets** no Prometheus e use o autocompletar de métricas antes de adaptar uma consulta.

No Grafana, importe o [Traefik Official Kubernetes Dashboard (ID 17347)](https://grafana.com/grafana/dashboards/17347-traefik-official-kubernetes-dashboard/), selecione a fonte `Prometheus` e examine as requisições, serviços e entrypoints. Esse dashboard é voltado ao Traefik em Kubernetes; dashboards para Swarm podem exigir labels e métricas diferentes.

## O que este laboratório cobre e o que falta

- **Métricas:** Prometheus coleta métricas do Traefik; Grafana consulta e apresenta esses dados.
- **Alertas:** esta configuração desativa o Alertmanager para reduzir o consumo local. Não há envio de notificações. Alertas úteis precisam de regras, um avaliador e um destino de notificação, além de um plano para evitar ruído.
- **Logs:** não há agregação centralizada. Para investigar um Pod, use `kubectl logs` e `kubectl describe pod`; Grafana não recebe os logs neste laboratório.
- **Host e cluster:** as coletas de nodes, cAdvisor, Services e Pods estão desativadas, assim como Node Exporter e kube-state-metrics. Este exemplo não fornece métricas de host nem visão de estado dos recursos Kubernetes.
- **Produção:** use armazenamento persistente, retenção planejada, autenticação e autorização adequadas, limites de recursos, backups e alertas com destinos testados. Não exponha Prometheus diretamente à Internet.

## Remover o laboratório

Os comandos abaixo removem as releases e os Secrets TLS dos namespaces do laboratório. A remoção do namespace Grafana também remove o Secret da senha. Reveja o namespace antes de executar:

```bash
helm uninstall grafana -n monitoring-grafana
helm uninstall prometheus -n monitoring-prometheus
kubectl delete namespace monitoring-grafana monitoring-prometheus
```

Como o armazenamento do Prometheus é efêmero, não há histórico a preservar neste laboratório.
