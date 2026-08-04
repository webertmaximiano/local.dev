# Guia de Configuração: Traefik no Kubernetes com HTTPS e Domínios Virtuais (Ambiente Local)

Este tutorial detalha o processo de configuração do Traefik como Ingress Controller no Kubernetes (via Docker Desktop), habilitando HTTPS com certificados autoassinados e domínios virtuais para ambiente de desenvolvimento local.

**Novidade:** Agora, o Traefik também será configurado para atuar como um *reverse proxy* para contêineres Docker, permitindo que ele gerencie aplicações tanto do Kubernetes quanto do Docker Compose, tudo a partir de uma única instância do Traefik!

## Pré-requisitos

*   **Ubuntu 24.04 LTS:** Sistema operacional.
*   **Docker Desktop:** Com o Kubernetes habilitado e em execução.
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
kubectl create secret tls local-dev-tls --cert=/home/webert/local.dev/traefik/certs/cert.pem --key=/home/webert/local.dev/traefik/certs/privkey.pem -n default
```

## 3. Instalação do Traefik com Helm

### 3.1. Adicionar Repositório Helm do Traefik

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

### 3.2. Criar o Arquivo `traefik-helm-values.yaml`

Crie o arquivo `/home/webert/local.dev/traefik/traefik-helm-values.yaml` com o conteúdo abaixo. Este arquivo configura o Traefik para operar com Kubernetes e Docker, padronizando as portas e habilitando o acesso ao socket do Docker.

```yaml
# traefik-helm-values.yaml

ports:
  web:
    port: 80
    exposedPort: 80
  websecure:
    port: 443
    exposedPort: 443
    tls:
      enabled: true
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
  - "--providers.docker.exposedbydefault=false"
  - "--providers.docker.endpoint=unix:///var/run/docker.sock"

# Monta o socket do Docker no pod do Traefik usando extraVolumes/extraVolumeMounts
controller:
  extraVolumes:
    - name: docker-socket
      hostPath:
        path: /var/run/docker.sock
  extraVolumeMounts:
    - name: docker-socket
      mountPath: /var/run/docker.sock
      readOnly: true

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
helm install traefik traefik/traefik -f /home/webert/local.dev/traefik/traefik-helm-values.yaml --wait
```

## 4. Protegendo o Dashboard do Traefik (Boa Prática Essencial)

**Por que isso é importante?** O dashboard do Traefik oferece controle total sobre o roteamento do seu cluster. Deixá-lo desprotegido, mesmo em um ambiente local, é uma má prática que pode levar a problemas de segurança se replicada em produção. Vamos protegê-lo com autenticação básica (usuário e senha).

### 4.1. Gerar Usuário e Senha

Usaremos o `htpasswd` para criar um par de usuário e senha. Vamos usar `admin` / `admin` como exemplo.

```bash
htpasswd -nb admin admin
# Saída: admin:$apr1$Hq.DiwS1$rXNYR7D8PHQPxJzFv1gEU1
```

### 4.2. Criar o Secret de Autenticação

Agora, armazenamos essas credenciais em um Secret do Kubernetes. 

**⚠️ Ponto de Atenção Crucial:** A string de senha gerada pelo `htpasswd` contém o caractere `$`. Ao usar o comando `echo`, o shell pode tentar interpretar isso como uma variável, corrompendo a senha. Para evitar isso, **devemos envolver a string em aspas simples (`' '`)** para garantir que ela seja tratada literalmente.

```bash
# Modo recomendado: crie o secret diretamente a partir da saída do htpasswd
htpasswd -nb admin admin | kubectl create secret generic traefik-dashboard-auth --from-file=users=/dev/stdin -n default
```

Se preferir inserir manualmente o hash, use o comando abaixo com aspas simples e cuidado extra com os sinais `$`:

```bash
# CUIDADO: Use aspas simples!
echo 'admin:$apr1$Hq.DiwS1$rXNYR7D8PHQPxJzFv1gEU1' | kubectl create secret generic traefik-dashboard-auth --from-file=users=/dev/stdin -n default
```

### 4.3. Criar o Middleware de Autenticação

Crie um arquivo `traefik/traefik-dashboard-auth-middleware.yaml` que define como o Traefik deve usar o secret que acabamos de criar.

```yaml
# traefik/traefik-dashboard-auth-middleware.yaml
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
kubectl apply -f /home/webert/local.dev/traefik/traefik-dashboard-auth-middleware.yaml
```

### 4.4. Atualizar o `traefik-helm-values.yaml`

Esta seção não é mais necessária, pois o `traefik-helm-values.yaml` já contém a configuração completa do `IngressRoute` para o dashboard. O `helm install` já aplica tudo de uma vez.

### 4.5. Aplicar as Alterações

Se você precisar atualizar a instalação do Traefik após a primeira vez (por exemplo, para mudar alguma configuração no `traefik-helm-values.yaml`), use o comando `helm upgrade`:

```bash
helm upgrade traefik traefik/traefik -f /home/webert/local.dev/traefik/traefik-helm-values.yaml --wait
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
curl -vk --user admin:admin https://traefik.local.dev/dashboard/
# Expectativa: HTTP/2 200
```

Ao acessar `https://traefik.local.dev/dashboard/` no navegador, uma janela de login deve aparecer.

### 5.3. Verificação do Provedor Docker

Para confirmar que o Traefik está enxergando os contêineres Docker, você pode:

1.  Acessar o Dashboard do Traefik (`https://traefik.local.dev/dashboard/`).
2.  Navegar até a seção **Providers**.
3.  Você deverá ver o provedor **Docker** listado, e ele começará a mostrar os serviços Docker que você iniciar com os labels corretos.

## 6. Implantação de uma Aplicação de Exemplo

(Esta seção permanece a mesma)
