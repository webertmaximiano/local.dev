# Guia de Configuração: Traefik no Kubernetes com HTTPS e Domínios Virtuais (Ambiente Local)

Este tutorial configura uma instância do Traefik como Ingress Controller para um cluster Kubernetes local. Ela é uma trilha separada do proxy Docker Swarm em `infra/swarm/`: não mantenha os dois ativos ao mesmo tempo se ambos publicarem as portas 80/443. Para voltar ao laboratório padrão, remova o Traefik Kubernetes antes de iniciar `make traefik-up`.

## Pré-requisitos

*   **Ubuntu 24.04 LTS:** Sistema operacional.
*   **Cluster Kubernetes local:** por exemplo, Docker Desktop ou K3s, iniciado e com o contexto correto selecionado.
*   **Helm 3:** Gerenciador de pacotes para Kubernetes.
*   **mkcert:** Ferramenta para criar certificados SSL/TLS locais confiáveis.
*   **htpasswd:** Ferramenta para criar arquivos de autenticação básica (geralmente instalada com o `apache2-utils`: `sudo apt install apache2-utils`).
*   **Entradas no `/etc/hosts`:** Certifique-se de que seu `/etc/hosts` contenha entradas para os domínios que você usará, apontando para `127.0.0.1`.

## 1. Limpeza de Instalações Anteriores (Opcional)

```bash
helm uninstall traefik --ignore-not-found
kubectl delete secret local-dev-tls --ignore-not-found
kubectl delete secret traefik-dashboard-auth --ignore-not-found
kubectl delete middleware traefik-dashboard-auth --ignore-not-found
# ... (outros comandos de limpeza)
```

## 2. Criação do Secret TLS no Kubernetes

```bash
kubectl create secret tls local-dev-tls --cert=kubernetes/networking/traefik/certs/local.dev/local.dev.crt --key=kubernetes/networking/traefik/certs/local.dev/local.dev.key -n default
```

## 3. Instalação do Traefik com Helm

### 3.1. Adicionar Repositório Helm do Traefik

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

### 3.2. Criar o Arquivo `traefik-helm-values.yaml`

Crie o arquivo `kubernetes/networking/traefik/traefik-helm-values.yaml` com o conteúdo abaixo. Este arquivo configura o Traefik para operar como Ingress Controller no Kubernetes (Docker Desktop), padronizando as portas e usando apenas o provedor Kubernetes.

```yaml
# kubernetes/networking/traefik/traefik-helm-values.yaml

ports:
  web:
    port: 80
    exposedPort: 80
  websecure:
    port: 443
    exposedPort: 443
  metrics:
    port: 9100
    exposedPort: 9100
  traefik:
    port: 8080
    exposedPort: 8080

api:
  dashboard: true

providers:
  kubernetesIngress:
    enabled: true

ingressClass:
  enabled: true
  isDefaultClass: true

service:
  type: LoadBalancer

additionalArguments:
  - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
  - "--entrypoints.web.http.redirections.entrypoint.scheme=https"

# Docker Desktop: se o host já reservar as portas 80/443, libere-as ou use NodePort
# em vez de LoadBalancer para acessar o Traefik localmente.

ingressRoute:
  dashboard:
    enabled: true
    matchRule: Host(`traefik.local.dev`)
    entryPoints:
      - websecure
    middlewares:
      - name: traefik-dashboard-auth
        namespace: default # Namespace onde o middleware foi criado
    tls:
      secretName: local-dev-tls
```

### 3.3. Instalar o Traefik

```bash
helm install traefik traefik/traefik -f kubernetes/networking/traefik/traefik-helm-values.yaml --wait
```

## 4. Protegendo o Dashboard do Traefik (Boa Prática Essencial)

**Por que isso é importante?** O dashboard do Traefik oferece controle total sobre o roteamento do seu cluster. Deixá-lo desprotegido, mesmo em um ambiente local, é uma má prática que pode levar a problemas de segurança se replicada em produção. Vamos protegê-lo com autenticação básica (usuário e senha).

### 4.1. Gerar Usuário e Senha

O `htpasswd` solicitará a senha sem exibi-la. Não passe a senha como argumento nem a salve neste repositório.

### 4.2. Criar o Secret de Autenticação

Agora, armazenamos essas credenciais em um Secret do Kubernetes. 

Crie o Secret diretamente a partir do hash, sem imprimi-lo ou armazená-lo em um arquivo versionado. `htpasswd` solicitará a senha interativamente:

```bash
htpasswd -nB admin | kubectl create secret generic traefik-dashboard-auth --from-file=users=/dev/stdin -n default
```

### 4.3. Criar o Middleware de Autenticação

Crie um arquivo `kubernetes/networking/traefik/traefik-dashboard-auth-middleware.yaml` que define como o Traefik deve usar o secret que acabamos de criar.

```yaml
# kubernetes/networking/traefik/traefik-dashboard-auth-middleware.yaml
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: traefik-dashboard-auth
spec:
  basicAuth:
    secret: traefik-dashboard-auth
```

Aplique este middleware ao cluster:
```bash
kubectl apply -f kubernetes/networking/traefik/traefik-dashboard-auth-middleware.yaml
```

### 4.4. Atualizar o `traefik-helm-values.yaml`

Esta seção não é mais necessária, pois o `traefik-helm-values.yaml` já contém a configuração completa do `IngressRoute` para o dashboard. O `helm install` já aplica tudo de uma vez.

### 4.5. Aplicar as Alterações

Se você precisar atualizar a instalação do Traefik após a primeira vez (por exemplo, para mudar alguma configuração no `traefik-helm-values.yaml`), use o comando `helm upgrade`:

```bash
helm upgrade traefik traefik/traefik -f kubernetes/networking/traefik/traefik-helm-values.yaml --wait
```

## 5. Verificação da Instalação e Segurança

### 5.1. Testar Acesso ao Dashboard (Sem Credenciais)

Este comando deve falhar com um erro `401 Unauthorized`.

```bash
curl -vk https://traefik.local.dev/dashboard/
# Expectativa: HTTP/2 401
```

> Nota: `https://traefik.local.dev/` pode retornar `404 page not found` porque o dashboard está exposto apenas em `/dashboard/`.

### 5.2. Testar Acesso ao Dashboard (Com Credenciais)

Este comando deve ter sucesso, retornando o HTML do dashboard.

```bash
curl -k --user admin https://traefik.local.dev/dashboard/
# Expectativa: HTTP/2 200
```

Ao acessar `https://traefik.local.dev/dashboard/` no navegador, uma janela de login deve aparecer.

### 5.3. Verificação do provedor Kubernetes

No Dashboard, confira se os routers e services Kubernetes aparecem depois de aplicar os manifests de uma aplicação. Este Traefik não descobre containers Docker nem serviços Compose; para esses ambientes, use o laboratório Swarm documentado em `infra/swarm/`.

## 6. Implantação de uma Aplicação de Exemplo

Aplique um Deployment, um Service e um recurso Ingress para uma aplicação. O exemplo de roteamento está em `kubernetes/networking/traefik/hello-world.yaml`.
