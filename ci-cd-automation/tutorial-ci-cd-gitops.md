# Guia de Automação: CI/CD e GitOps com GitHub Actions e Argo CD

Este guia aborda a **Fase 3** do seu aprendizado: a automação do ciclo de vida do software através de **Integração Contínua (CI)**, **Entrega Contínua (CD)** e **GitOps**. Utilizaremos o **GitHub Actions** para CI e o **Argo CD** para CD, com foco em implantações no Kubernetes.

## 🚀 O que é CI/CD e GitOps?

*   **Integração Contínua (CI):** É a prática de integrar as alterações de código de vários desenvolvedores em um repositório compartilhado várias vezes ao dia. Cada integração é verificada por builds automatizados e testes, detectando erros rapidamente.
*   **Entrega Contínua (CD):** Estende a CI, automatizando a entrega de código para ambientes de teste e/ou produção após a fase de CI. O objetivo é ter um pipeline que possa liberar novas versões de software de forma rápida e confiável.
*   **GitOps:** É uma abordagem para implementar CD que usa o Git como a única fonte de verdade para a infraestrutura declarativa e as aplicações. Com o GitOps, você descreve o estado desejado do seu ambiente em arquivos Git, e uma ferramenta (como o Argo CD) garante que o ambiente real corresponda a esse estado.

## 🛠️ Pré-requisitos

Para entender e aplicar este guia, você precisará:

*   Conhecimento básico de Git e GitHub.
*   Conhecimento básico de Docker e contêineres.
*   Conhecimento básico de Kubernetes e seus conceitos (Pods, Deployments, Services, Ingress).
*   **Importante:** Para a execução completa e prática dos exemplos de CD com Argo CD, você precisará de um **cluster Kubernetes remoto e acessível** (ex: Google Kubernetes Engine - GKE, Amazon Elastic Kubernetes Service - EKS, ou uma VPS com K3s/MicroK8s). O Docker Desktop com Kubernetes integrado é excelente para desenvolvimento local, mas não é adequado para a fase de CD com Argo CD, pois ele precisa de um cluster persistente e acessível externamente.

## 1. Integração Contínua (CI) com GitHub Actions

O GitHub Actions permite automatizar, personalizar e executar seus fluxos de trabalho de desenvolvimento de software diretamente no seu repositório GitHub. Usaremos ele para:

*   Rodar testes da sua aplicação.
*   Construir imagens Docker da sua aplicação.
*   Enviar (push) as imagens Docker para um registro de contêineres (ex: GitHub Container Registry - `ghcr.io`).

### 1.1. Estrutura de um Workflow

Os workflows do GitHub Actions são definidos em arquivos YAML na pasta `.github/workflows/` do seu repositório.

### 1.2. Exemplo de Workflow: Build e Push de Imagem Docker

Considere uma aplicação Node.js simples com um `Dockerfile`. Este workflow será acionado a cada `push` para o branch `main`.

**Arquivo:** `.github/workflows/build-and-push.yml`

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write # Permissão para escrever no GitHub Container Registry

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Log in to the Container registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

**Explicação:**

*   `on: push: branches: - main`: O workflow é acionado em cada `push` para o branch `main`.
*   `permissions: packages: write`: Concede permissão para enviar imagens para o GitHub Container Registry.
*   `docker/login-action@v3`: Faz login no registro usando seu usuário do GitHub (`github.actor`) e um token de acesso gerado automaticamente (`secrets.GITHUB_TOKEN`).
*   `docker/metadata-action@v5`: Gera tags e labels para a imagem Docker com base nas informações do Git (ex: `ghcr.io/seu-usuario/seu-repo:latest`, `ghcr.io/seu-usuario/seu-repo:v1.0.0`).
*   `docker/build-push-action@v5`: Constrói a imagem Docker e a envia para o registro.

## 2. Entrega Contínua (CD) com GitOps e Argo CD

O **Argo CD** é uma ferramenta declarativa de CD baseada em GitOps para Kubernetes. Ele automatiza a implantação de aplicações no seu cluster, monitorando um repositório Git para mudanças e garantindo que o estado do cluster corresponda ao que está definido no Git.

### 2.1. Como o GitOps Funciona com Argo CD

1.  **Repositório de Código (App Repo):** Contém o código-fonte da sua aplicação e o `Dockerfile`.
2.  **Repositório de Configuração (GitOps Repo):** Contém os manifestos Kubernetes (YAMLs) que descrevem o estado desejado da sua aplicação no cluster. Este é o "único fonte de verdade".
3.  **Pipeline CI (GitHub Actions):** Quando há um `push` no App Repo, o CI constrói a imagem Docker e a envia para um registro. Em seguida, ele **atualiza o manifesto da imagem** no GitOps Repo (ex: muda `minha-app:v1.0.0` para `minha-app:v1.0.1`).
4.  **Argo CD:** Monitora o GitOps Repo. Ao detectar uma mudança no manifesto da imagem, ele automaticamente puxa essa mudança e a aplica ao cluster Kubernetes, garantindo que a nova versão da aplicação seja implantada.

### 2.2. Instalação do Argo CD (no seu Cluster Remoto)

Para instalar o Argo CD no seu cluster Kubernetes remoto:

```bash
# Crie o namespace para o Argo CD
kubectl create namespace argocd

# Instale o Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Aguarde a inicialização dos pods
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Obtenha a senha inicial do admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Exponha a UI do Argo CD (ex: via LoadBalancer ou Ingress)
# Para LoadBalancer (se seu cluster suportar):
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
# Ou configure um Ingress para argocd-server na porta 80
```

### 2.3. Configurando uma Aplicação no Argo CD

Após instalar o Argo CD, você pode acessá-lo via navegador (usando o IP do LoadBalancer ou o domínio configurado no Ingress) e fazer login com `admin` e a senha obtida.

Para registrar sua aplicação no Argo CD, você pode usar a UI ou a CLI do Argo CD (`argocd`).

**Exemplo de criação de aplicação via CLI:**

```bash
# Faça login no Argo CD CLI
argocd login <ARGOCD_SERVER_URL>

# Adicione seu repositório GitOps (onde estão os manifestos Kubernetes)
argocd repo add https://github.com/SEU_USUARIO/seu-gitops-repo.git --username <SEU_USUARIO_GIT> --password <SEU_TOKEN_GIT>

# Crie a aplicação no Argo CD
argocd app create minha-app \
  --repo https://github.com/SEU_USUARIO/seu-gitops-repo.git \
  --path k8s-manifests/minha-app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated
```

**Explicação:**

*   `--repo`: O URL do seu repositório GitOps.
*   `--path`: O caminho dentro do repositório onde estão os manifestos Kubernetes da sua aplicação.
*   `--dest-server`: O servidor Kubernetes de destino (geralmente `https://kubernetes.default.svc` para o cluster onde o Argo CD está rodando).
*   `--dest-namespace`: O namespace onde a aplicação será implantada.
*   `--sync-policy automated`: Configura o Argo CD para sincronizar automaticamente as mudanças do Git para o cluster.

### 2.4. Exemplo de Manifesto Kubernetes (no GitOps Repo)

Seu repositório GitOps (`seu-gitops-repo.git`) conteria algo como:

**Arquivo:** `k8s-manifests/minha-app/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minha-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minha-app
  template:
    metadata:
      labels:
        app: minha-app
    spec:
      containers:
      - name: minha-app
        image: ghcr.io/SEU_USUARIO/seu-repo:latest # Esta tag será atualizada pelo CI
        ports:
        - containerPort: 80
```

Quando o GitHub Actions construir uma nova imagem, ele faria um `git commit` e `git push` para atualizar a tag `latest` (ou uma tag de versão específica) neste arquivo `deployment.yaml` no seu repositório GitOps. O Argo CD detectaria essa mudança e implantaria a nova versão no cluster.

## Conclusão

CI/CD e GitOps são pilares do desenvolvimento moderno, permitindo entregas rápidas, confiáveis e auditáveis. Embora a configuração completa do Argo CD exija um cluster remoto, entender os conceitos e a interação entre GitHub Actions e Argo CD é um passo fundamental para agilizar seu futuro na nuvem.
