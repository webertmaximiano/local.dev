# 🚀 Guia Definitivo: Desenvolvimento Kubernetes Local no Ubuntu 24.04 com Skaffold e Hot Reload

Este guia apresenta uma solução completa para desenvolver aplicações em um cluster Kubernetes local (via Docker Desktop) no Ubuntu 24.04. O objetivo é resolver problemas comuns de sincronização de arquivos e permissões, estabelecendo um fluxo de trabalho profissional com **hot reload** instantâneo.

Nosso projeto de exemplo é um aplicativo **React + Vite** chamado `hello-world-app`, localizado no diretório `/local.dev/hello-world-app`.

## 🎯 O Desafio

Ao usar o Docker Desktop no Ubuntu 24.04, desenvolvedores enfrentam dois grandes obstáculos que impedem o "live reload":

1.  **Restrição do AppArmor:** Uma nova configuração de segurança do Ubuntu causa instabilidade no Docker Desktop.
2.  **Falha na Sincronização de Volumes (`hostPath`):** A camada de virtualização do Docker Desktop apresenta bugs ao compartilhar arquivos do host com os contêineres. Montar volumes diretamente (`hostPath`) não é confiável, fazendo com que os pods entrem em `CrashLoopBackOff` por não encontrarem os arquivos da aplicação.

## ✨ A Solução: Orquestração com Skaffold

Em vez de forçar o uso de volumes, a solução mais inteligente é adotar o **Skaffold**, uma ferramenta de orquestração de desenvolvimento que contorna o problema.

O guia está dividido em três etapas:

1.  **Configuração do Ambiente:** Corrigir a pré-condição do sistema operacional.
2.  **Containerização Robusta:** Criar um `Dockerfile` otimizado e à prova de erros de permissão.
3.  **Orquestração Ágil com Skaffold:** Automatizar o ciclo de build, deploy e sincronização de arquivos para um "hot reload" instantâneo.

---

### Etapa 1: Corrigir a Restrição do AppArmor no Ubuntu 24.04

Este passo é **obrigatório** para garantir a estabilidade do Docker Desktop.

1.  **Abra o terminal** e edite o arquivo `/etc/sysctl.conf`:
    ```bash
    sudo nano /etc/sysctl.conf
    ```

2.  Adicione a seguinte linha ao final do arquivo:
    ```
    kernel.apparmor_restrict_unprivileged_userns=0
    ```

3.  Salve, feche o editor e aplique a alteração:
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

Vamos configurar os arquivos necessários dentro do diretório do projeto: `/local.dev/hello-world-app`.

#### Arquivo 1: `Dockerfile.dev`

Este `Dockerfile` é a receita para criar nossa imagem de desenvolvimento. Ele resolve problemas de versão do Node.js para o Vite e questões de permissão.

```dockerfile
# Dockerfile.dev
# Usa a versão 24 do Node.js, compatível com o Vite moderno.
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

# Copia os arquivos de dependência e instala, otimizando o cache do Docker.
COPY --chown=node:node package*.json ./
RUN npm install

# Copia o resto do código da aplicação.
COPY --chown=node:node . .

# Expõe a porta padrão do Vite.
EXPOSE 5173

# Roda o servidor de desenvolvimento com a flag '--host' para torná-lo acessível.
CMD ["npm", "run", "dev", "--", "--host"]
```

#### Arquivo 2: `vite.config.js`

Configuramos o Vite para aceitar requisições do nosso Ingress (`agilizando.local.dev`) e para funcionar corretamente com o Hot Module Replacement (HMR) dentro do Docker.

```javascript
// vite.config.js
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

---

### Etapa 3: Orquestração com Kubernetes e Skaffold

Com a aplicação pronta, vamos instalar e configurar o Skaffold para gerenciar nosso ambiente.

#### 3.1: Instalar o Skaffold

No seu terminal, execute o seguinte comando para baixar e instalar o Skaffold:

```bash
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/
```
Isso fará o download do executável e o moverá para uma pasta do sistema, tornando o comando `skaffold` globalmente acessível.

#### 3.2: Configurar os Manifestos

Agora, crie os dois arquivos de configuração a seguir na raiz do seu projeto.

##### Arquivo 3: `k8s-manifest.yaml`

Este é o nosso manifesto Kubernetes. Ele descreve o `Deployment`, o `Service` e o `Ingress` da aplicação.

```yaml
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
```

##### Arquivo 4: `skaffold.yaml`

Este é o cérebro da nossa operação. Ele diz ao Skaffold como construir, implantar e, crucialmente, sincronizar nossos arquivos para um **hot reload** rápido.

```yaml
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
```

---

### 🚀 Executando o Ambiente de Desenvolvimento

Com todos os quatro arquivos configurados na pasta `/local.dev/hello-world-app`, o fluxo de trabalho se resume a um único comando no terminal:

```bash
skaffold dev --port-forward --trigger=polling
```

-   `skaffold dev`: Inicia o modo de desenvolvimento.
-   `--port-forward`: Expõe a aplicação na porta `4503` do seu `localhost`.
-   `--trigger=polling`: A flag **essencial** que força o Skaffold a detectar mudanças de arquivo no seu ambiente Ubuntu.

Agora, ao editar e salvar qualquer arquivo (`.js`, `.css`, etc.) na sua pasta `src`, o Skaffold irá copiar instantaneamente o arquivo alterado para dentro do contêiner em execução, e o Vite atualizará o navegador automaticamente.

Você terá a robustez de um deploy Kubernetes com a velocidade de um desenvolvimento local tradicional!
