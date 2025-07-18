# Guia de Configuração: Traefik no Kubernetes com HTTPS e Domínios Virtuais (Ambiente Local)

Este tutorial detalha o processo de configuração do Traefik como Ingress Controller no Kubernetes (via Docker Desktop), habilitando HTTPS com certificados autoassinados e domínios virtuais para ambiente de desenvolvimento local.

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

Crie o arquivo `/home/webert/local.dev/traefik/traefik-helm-values.yaml` com o conteúdo inicial.

```yaml
# traefik-helm-values.yaml

ports:
  web:
    port: 8000
    exposedPort: 80
  websecure:
    port: 8443
    exposedPort: 443
    tls:
      enabled: true

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
# CUIDADO: Use aspas simples!
echo 'admin:$apr1$Hq.DiwS1$rXNYR7D8PHQPxJzFv1gEU1' | kubectl create secret generic traefik-dashboard-auth --from-file=users=/dev/stdin
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

Agora, vamos editar nosso `traefik-helm-values.yaml` para criar o `IngressRoute` para o dashboard e aplicar o middleware a ele.

```yaml
# ... (conteúdo anterior do values.yaml)

# Adicione ou modifique esta seção no final do arquivo
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

### 4.5. Aplicar as Alterações

Execute um `helm upgrade` para que o Traefik recarregue a configuração com as novas definições de segurança.

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

### 5.2. Testar Acesso ao Dashboard (Com Credenciais)

Este comando deve ter sucesso, retornando o HTML do dashboard.

```bash
curl -vk --user admin:admin https://traefik.local.dev/dashboard/
# Expectativa: HTTP/2 200
```

Ao acessar `https://traefik.local.dev/dashboard/` no navegador, uma janela de login deve aparecer.

## 6. Implantação de uma Aplicação de Exemplo

(Esta seção permanece a mesma)

...