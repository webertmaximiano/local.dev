# Guia de Configuração: Monitoramento com Prometheus e Grafana para Traefik no Kubernetes

Este tutorial detalha a instalação e configuração do Prometheus e Grafana no Kubernetes para monitorar as métricas do Traefik, utilizando Helm para a instalação e acesso via domínios virtuais.

## Pré-requisitos

*   **Ambiente Kubernetes:** Docker Desktop com Kubernetes habilitado e em execução.
*   **Traefik:** Traefik instalado e funcionando como Ingress Controller, expondo métricas na porta 9100 (padrão do Helm chart).
*   **Helm 3:** Gerenciador de pacotes para Kubernetes.
*   **`kubectl`:** Ferramenta de linha de comando para interagir com o cluster Kubernetes.
*   **Entradas no `/etc/hosts`:** Certifique-se de que seu `/etc/hosts` contenha entradas para os domínios que você usará, apontando para `127.0.0.1`. Exemplo:
    ```
    127.0.0.1 prometheus.local.dev
    127.0.0.1 grafana.local.dev
    ```

## 1. Limpeza de Instalações Anteriores (Opcional, mas Recomendado)

Se você tentou instalar o Prometheus ou Grafana anteriormente, é crucial remover todas as instalações e recursos para evitar conflitos.

```bash
helm uninstall prometheus --namespace monitoring-prometheus --ignore-not-found
helm uninstall grafana --namespace monitoring-grafana --ignore-not-found
kubectl delete namespace monitoring-prometheus --ignore-not-found
kubectl delete namespace monitoring-grafana --ignore-not-found
```

## 2. Criação de Namespaces

Vamos criar namespaces dedicados para o Prometheus e Grafana para melhor organização.

```bash
kubectl create namespace monitoring-prometheus
kubectl create namespace monitoring-grafana
```

## 3. Instalação do Prometheus

Vamos instalar o Prometheus, configurando-o para coletar apenas as métricas do Traefik.

### 3.1. Adicionar Repositório Helm do Prometheus

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 3.2. Criar o Arquivo `monitoring/prometheus-values.yaml`

Crie o arquivo `/home/webert/local.dev/monitoring/prometheus-values.yaml` com o seguinte conteúdo:

```yaml
# monitoring/prometheus-values.yaml

alertmanager:
  enabled: false

nodeExporter:
  enabled: false

kubeStateMetrics:
  enabled: false

prometheus-pushgateway:
  enabled: false

server:
  # Configuração do Prometheus para coletar métricas do Traefik
  extraScrapeConfigs: |
    - job_name: 'traefik'
      metrics_path: /metrics
      scheme: http
      kubernetes_sd_configs:
        - role: pod
          namespaces:
            names: ['default'] # Namespace onde o Traefik está rodando
      relabel_configs:
        - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
          action: keep
          regex: traefik
        - source_labels: [__meta_kubernetes_pod_container_port_name]
          action: keep
          regex: metrics # Nome da porta de métricas no pod do Traefik (padrão do Helm chart do Traefik)
        - source_labels: [__address__]
          action: replace
          regex: ([^:]+):\d+
          replacement: $1:9100 # Substitui a porta pelo 9100 (porta padrão de métricas do Traefik)
          target_label: __address__
```

### 3.3. Instalar o Prometheus

```bash
helm install prometheus prometheus-community/prometheus -f /home/webert/local.dev/monitoring/prometheus-values.yaml --namespace monitoring-prometheus --wait
```

## 4. Instalação do Grafana

Vamos instalar o Grafana, configurando-o para usar o Prometheus como fonte de dados e expondo-o via Traefik.

### 4.1. Adicionar Repositório Helm do Grafana

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### 4.2. Criar um Secret para as Credenciais de Administrador do Grafana

```bash
kubectl create secret generic grafana-admin-secret --from-literal=admin-user=admin --from-literal=admin-password=admin -n monitoring-grafana
```

### 4.3. Criar o Arquivo `monitoring/grafana-values.yaml`

Crie o arquivo `/home/webert/local.dev/monitoring/grafana-values.yaml` com o seguinte conteúdo:

```yaml
# monitoring/grafana-values.yaml

admin:
  existingSecret: grafana-admin-secret

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-server.monitoring-prometheus.svc.cluster.local # URL do serviço Prometheus
        access: proxy
        isDefault: true

# Configura o Ingress para o Grafana
ingress:
  enabled: true
  ingressClassName: traefik
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
  hosts:
    - grafana.local.dev
  tls:
    - hosts:
        - grafana.local.dev
      secretName: local-dev-tls # Reutiliza o Secret TLS que já criamos

# Configura o Service para o Grafana
service:
  type: ClusterIP
```

### 4.4. Instalar o Grafana

```bash
helm install grafana grafana/grafana -f /home/webert/local.dev/monitoring/grafana-values.yaml --namespace monitoring-grafana --wait
```

## 5. Verificação e Testes

### 5.1. Verificar Pods e Serviços

```bash
kubectl get pods -n monitoring-prometheus -l app=prometheus-server
kubectl get pods -n monitoring-grafana -l app.kubernetes.io/name=grafana
```

### 5.2. Acessar o Dashboard do Grafana

Abra seu navegador e acesse: `https://grafana.local.dev`

Faça login com o usuário `admin` e a senha que você definiu no Secret (`admin` por padrão).

### 5.3. Verificar Fonte de Dados e Métricas do Traefik no Grafana

Após logar no Grafana:

1.  Navegue até "Configuration" (ícone de engrenagem) -> "Data sources". Confirme que o Prometheus está configurado.
2.  Vá para "Explore" (ícone de bússola) e selecione a fonte de dados Prometheus. Digite `traefik_` e veja se as métricas do Traefik aparecem no autocompletar.

### 5.4. Importar Dashboard de Exemplo do Traefik no Grafana

Você pode importar um dashboard oficial do Traefik para o Grafana. Um bom ponto de partida é o dashboard "Traefik Dashboard" (ID: 13960) ou "Traefik 2.x" (ID: 12750).

1.  No Grafana, vá para "Dashboards" (ícone de dashboards) -> "Import".
2.  Insira o ID do dashboard (ex: `13960`) e clique em "Load".
3.  Selecione a fonte de dados Prometheus e clique em "Import".

---

Com estes passos, você terá um ambiente de monitoramento completo com Prometheus e Grafana, coletando e visualizando as métricas do Traefik no seu cluster Kubernetes local.