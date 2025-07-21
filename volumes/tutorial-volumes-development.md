# Guia Definitivo: Desenvolvimento Kubernetes Local no Ubuntu 24.04 com Skaffold e Hot Reload

Este guia documenta a solução completa para desenvolver aplicações em um cluster Kubernetes local (via Docker Desktop) no Ubuntu 24.04, resolvendo os problemas de sincronização de arquivos e permissões, e estabelecendo um fluxo de trabalho profissional com "hot reload" instantâneo.

Nosso projeto de exemplo é um aplicativo **React + Vite** chamado `hello-world-app`, localizado no diretório `/local.dev/hello-world-app`.

## O Desafio Inicial

Ao usar o Docker Desktop no Ubuntu 24.04, desenvolvedores enfrentam dois grandes obstáculos que quebram o fluxo de "live reload":

1.  **Restrição do AppArmor:** Uma nova configuração de segurança do Ubuntu impede que o Docker Desktop funcione corretamente, causando instabilidade.
2.  **Falha na Sincronização de Volumes (`hostPath`):** A camada de virtualização do Docker Desktop apresenta bugs ao compartilhar arquivos do sistema host com os contêineres do Kubernetes. Montar volumes diretamente (`hostPath`) se mostra não confiável, fazendo com que os pods não encontrem os arquivos da aplicação e entrem em `CrashLoopBackOff`.

## A Solução Evolutiva: De Volumes a Skaffold

A solução não é tentar forçar os volumes a funcionar, mas sim adotar uma ferramenta de orquestração de desenvolvimento que contorne o problema de forma mais inteligente: o **Skaffold**.

Este guia é dividido em três etapas:

1.  **Configuração do Ambiente:** Corrigir a pré-condição do sistema operacional.
2.  **Containerização Correta:** Criar um `Dockerfile` robusto e à prova de erros de permissão.
3.  **Orquestração Ágil com Skaffold:** Usar o Skaffold para automatizar o ciclo de build, deploy e, o mais importante, a sincronização de arquivos para um "hot reload" instantâneo.

---

### Etapa 1: Corrigir a Restrição do AppArmor no Ubuntu 24.04

Esta etapa é obrigatória para a estabilidade do Docker Desktop.

1.  **Abra o Terminal** e edite `sysctl.conf`:
    ```bash
    sudo nano /etc/sysctl.conf
    ```
2.  Adicione a seguinte linha ao final do arquivo:
    ```
    kernel.apparmor_restrict_unprivileged_userns=0
    ```
3.  Salve, feche e aplique a alteração:
    ```bash
    sudo sysctl -p
    ```
4.  Reinicie o Docker Desktop para que a mudança tenha efeito:
    ```bash
    systemctl --user restart docker-desktop
    ```
Com o ambiente estável, podemos focar na aplicação.

---

### Etapa 2: Preparando a Aplicação e o `Dockerfile`

Vamos configurar os arquivos necessários dentro da nossa pasta de projeto `/local.dev/hello-world-app`.

#### Arquivo 1: `Dockerfile.dev`

Este `Dockerfile` é a receita para criar nossa imagem de desenvolvimento. Ele resolve os problemas de versão do Node.js para o Vite e os problemas de permissão.

```dockerfile
# Dockerfile.dev
# Usa a versão 20 do Node.js, que é compatível com o Vite moderno.
FROM node:24-alpine

# Argumentos para UID/GID para corresponder ao nosso usuário host.
ARG UID=1000
ARG GID=1000

# Instala ferramentas para modificar o usuário e o grupo.
RUN apk add --no-cache shadow && \
    groupmod -g ${GID} node && \
    usermod -u ${UID} node

# Define o diretório de trabalho.
WORKDIR /home/node/app

# Ponto chave: Dá a propriedade do diretório ao usuário 'node' ANTES de qualquer operação.
RUN chown -R node:node /home/node/app

# Muda para o usuário 'node' para todas as operações subsequentes.
USER node

# Copia os arquivos de dependência e instala, o que otimiza o cache do Docker.
COPY --chown=node:node package*.json ./
RUN npm install

# Copia o resto do código da aplicação.
COPY --chown=node:node . .

# Expõe a porta padrão do Vite.
EXPOSE 5173

# Rodar o servidor de desenvolvimento com a flag '--host' para torná-lo acessível.
CMD ["npm", "run", "dev", "--", "--host"]

```
#### Arquivo 2: `vite.config.js`
Configuramos o Vite para aceitar requisições do nosso Ingress (agilizando.local.dev) e para funcionar bem com o Hot Module Replacement (HMR) dentro do Docker.

```vite.config.js

import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    hmr: {
        host: 'localhost',
    },
    watch: {
      usePolling: true 
    },
    // Permite que o Ingress acesse o servidor.
    allowedHosts: ['agilizando.local.dev']
  }
})

```
#### Etapa 3: Orquestração com Kubernetes e Skaffold
Com a aplicação pronta, vamos descrever como executá-la no Kubernetes e como o Skaffold vai gerenciar tudo.

Arquivo 3: k8s-manifest.yaml
Este é o nosso manifesto Kubernetes. Ele descreve o Deployment para rodar a aplicação, o Service para expô-la internamente e o Ingress para acessá-la pelo navegador. Note que não usamos mais hostPath, pois o Skaffold cuidará da sincronização.

YAML

# k8s-manifest.yaml
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
        image: hello-world-app-dev # Esta imagem será gerenciada pelo Skaffold
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5173
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
      targetPort: 5173
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
spec:
  rules:
  - host: agilizando.local.dev
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-world-service
            port:
              number: 80
Arquivo 4: skaffold.yaml
Este é o cérebro da nossa operação. Ele diz ao Skaffold como construir, implantar e, crucialmente, sincronizar nossos arquivos para um "hot reload" rápido.

YAML

# skaffold.yaml
apiVersion: skaffold/v4beta1
kind: Config
metadata:
  name: hello-world-app
build:
  artifacts:
    - image: hello-world-app-dev
      docker:
        dockerfile: Dockerfile.dev
      # A MÁGICA DO HOT RELOAD: Sincroniza arquivos em vez de reconstruir a imagem.
      sync:
        manual:
          - src: 'src/**/*.{js,jsx,ts,tsx,css,html}'
            dest: .
          - src: 'public/**/*'
            dest: .
          - src: 'vite.config.js'
            dest: .
manifests:
  rawYaml:
    - k8s-manifest.yaml
portForward:
  # Expõe o serviço no localhost para fácil acesso.
  - resourceType: service
    resourceName: hello-world-service
    port: 80
    localPort: 4503
Executando o Ambiente de Desenvolvimento
Com todos os quatro arquivos configurados na pasta /local.dev/hello-world-app, o fluxo de trabalho se resume a um único comando no terminal:

Bash

skaffold dev --port-forward --trigger=polling
skaffold dev: Inicia o modo de desenvolvimento.

--port-forward: Expõe a aplicação na porta 4503 do seu localhost.

--trigger=polling: A flag essencial que força o Skaffold a detectar mudanças de arquivo no seu ambiente Ubuntu.

Agora, quando você edita e salva qualquer arquivo javascript, css, etc., na sua pasta src, o Skaffold irá instantaneamente copiar o arquivo alterado para dentro do contêiner em execução, e o Vite irá atualizar o navegador automaticamente. Você tem a robustez de um deploy Kubernetes com a velocidade de um desenvolvimento local tradicion