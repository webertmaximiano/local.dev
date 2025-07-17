# Guia de Configuração: Traefik no Kubernetes com HTTPS e Domínios Virtuais (Ambiente Local)

Este tutorial detalha o processo de configuração do Traefik como Ingress Controller no Kubernetes (via Docker Desktop), habilitando HTTPS com certificados autoassinados e domínios virtuais para ambiente de desenvolvimento local.

## Pré-requisitos

*   **Ubuntu 24.04 LTS:** Sistema operacional.
*   **Docker Desktop:** Com o Kubernetes habilitado e em execução.
    *   Verifique o status do Kubernetes no Docker Desktop.
    *   Confirme que o `kubectl` está configurado para o contexto `docker-desktop` (`kubectl config get-contexts`).
*   **Helm 3:** Gerenciador de pacotes para Kubernetes.
    *   Verifique a instalação: `helm version`.
*   **mkcert:** Ferramenta para criar certificados SSL/TLS locais confiáveis.
    *   Instale se ainda não tiver: `sudo apt install libnss3-tools` e `go install filippo.io/mkcert@latest && go install filippo.io/mkcert/cmd/mkcert@latest`.
    *   Configure a CA local: `mkcert -install`.
    *   Crie os certificados wildcard: `mkcert -key-file privkey.pem -cert-file cert.pem "*.local.dev" local.dev`. Mova-os para `traefik/certs/`.
*   **Entradas no `/etc/hosts`:** Certifique-se de que seu `/etc/hosts` contenha entradas para os domínios que você usará, apontando para `127.0.0.1`. Exemplo:
    ```
    127.0.0.1 traefik.local.dev
    127.0.0.1 agilizando.local.dev
    ```

## 1. Limpeza de Instalações Anteriores (Opcional, mas Recomendado)

Se você tentou instalar o Traefik anteriormente, é crucial remover todas as instalações e recursos para evitar conflitos.

```bash
helm uninstall traefik --ignore-not-found
kubectl delete secret local-dev-tls --ignore-not-found
kubectl delete deployment traefik --ignore-not-found
kubectl delete service traefik --ignore-not-found
kubectl delete ingress traefik-dashboard-ingress --ignore-not-found
kubectl delete ingressroute traefik-dashboard --ignore-not-found
kubectl delete ingressclass traefik --ignore-not-found
kubectl delete clusterrole traefik-ingress-controller --ignore-not-found
kubectl delete clusterrolebinding traefik-ingress-controller --ignore-not-found
kubectl delete serviceaccount traefik-ingress-controller --ignore-not-found
kubectl delete -f https://raw.githubusercontent.com/traefik/traefik/v2.11/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml --ignore-not-found
```

## 2. Criação do Secret TLS no Kubernetes

O Traefik precisará do seu certificado wildcard para habilitar HTTPS. Crie um Secret do Kubernetes a partir dos arquivos `cert.pem` e `privkey.pem` gerados pelo `mkcert`.

```bash
kubectl create secret tls local-dev-tls --cert=/home/webert/local.dev/traefik/certs/cert.pem --key=/home/webert/local.dev/traefik/certs/privkey.pem -n default
```

## 3. Instalação do Traefik com Helm

Vamos instalar o Traefik usando o Helm, configurando-o para usar o certificado TLS, habilitar o dashboard e rotear o tráfego.

### 3.1. Adicionar Repositório Helm do Traefik

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

### 3.2. Criar o Arquivo `traefik-helm-values.yaml`

Crie o arquivo `/home/webert/local.dev/traefik/traefik-helm-values.yaml` com o seguinte conteúdo:

```yaml
# traefik-helm-values.yaml

# Configurações gerais do Traefik
ports:
  traefik:
    port: 8080
    expose:
      default: false
    exposedPort: 8080
    protocol: TCP
  web:
    port: 8000
    expose:
      default: true
    exposedPort: 80
    protocol: TCP
  websecure:
    port: 8443
    expose:
      default: true
    exposedPort: 443
    protocol: TCP
    tls:
      enabled: true

# Habilita o dashboard e a API
api:
  dashboard: true
  insecure: true # Apenas para desenvolvimento local, não use em produção

# Configura o provedor Kubernetes Ingress
providers:
  kubernetesIngress:
    enabled: true
    ingressClass: traefik
    publishedService:
      enabled: true

# Configura o TLS
tlsStore:
  default:
    defaultCertificate:
      secretName: local-dev-tls # Usa o Secret TLS que já criamos

# Configura o IngressClass
ingressClass:
  enabled: true
  isDefaultClass: false
  name: traefik

# Configura o Service para o Traefik
service:
  type: LoadBalancer # Ou NodePort se LoadBalancer não funcionar no Docker Desktop
  annotations: {}
  spec:
    externalTrafficPolicy: Cluster

# IngressRoute para o dashboard
ingressRoute:
  dashboard:
    enabled: true
    matchRule: Host(`traefik.local.dev`)
    entryPoints:
      - websecure # Usar o entrypoint 'websecure' para o dashboard

# Redirecionamento HTTP para HTTPS para o entrypoint web
additionalArguments:
  - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
  - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
```

### 3.3. Instalar o Traefik

```bash
helm install traefik traefik/traefik -f /home/webert/local.dev/traefik/traefik-helm-values.yaml --wait
```

## 4. Verificação da Instalação do Traefik

### 4.1. Verificar Pods e Serviços do Traefik

```bash
kubectl get pods -l app.kubernetes.io/name=traefik
kubectl get svc traefik -o wide
```

### 4.2. Testar Acesso ao Dashboard do Traefik

Abra seu navegador e acesse: `https://traefik.local.dev/dashboard/`

Você pode ver um aviso de certificado (devido ao certificado autoassinado do `mkcert`). Aceite o risco para prosseguir.

Para testar via `curl` (ignorando o erro de certificado):

```bash
curl -vk https://traefik.local.dev/dashboard/
```

**Expectativa:** O `curl` deve retornar um `HTTP/2 200 OK` e o HTML do dashboard. O certificado deve ser o `mkcert` (não o `TRAEFIK DEFAULT CERT`).

## 5. Implantação de uma Aplicação de Exemplo

Vamos implantar uma aplicação "Hello World" simples e expô-la via Traefik.

### 5.1. Criar o Arquivo `hello-world.yaml`

Crie o arquivo `/home/webert/local.dev/traefik/hello-world.yaml` com o seguinte conteúdo:

```yaml
# hello-world.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: nginxdemos/hello
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
spec:
  selector:
    app: hello-world
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: hello-world-ingress
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`agilizando.local.dev`)
      kind: Rule
      services:
        - name: hello-world-service
          port: 80
  tls:
    secretName: local-dev-tls # Nome do Secret TLS que já criamos
```

### 5.2. Aplicar os Manifests da Aplicação

```bash
kubectl apply -f /home/webert/local.dev/traefik/hello-world.yaml
```

## 6. Testar Acesso à Aplicação de Exemplo

Abra seu navegador e acesse: `https://agilizando.local.dev/`

Para testar via `curl` (ignorando o erro de certificado):

```bash
curl -vk https://agilizando.local.dev/
```

**Expectativa:** O `curl` deve retornar um `HTTP/2 200 OK` e a página "Hello World" do Nginx. O certificado deve ser o `mkcert` (`*.local.dev`).

---

Com estes passos, você terá um ambiente de desenvolvimento local com Traefik no Kubernetes, HTTPS e domínios virtuais funcionando para suas aplicações e para o dashboard do Traefik.
