# Guia: Adicionando Domínios Virtuais ao Traefik Kubernetes

Este guia é exclusivo da trilha Kubernetes. O Traefik do laboratório Swarm tem configuração e certificados próprios em `infra/swarm/`; não compartilhe os Secrets entre os ambientes.

## Pré-requisitos

*   **mkcert:** Para gerar certificados SSL/TLS locais confiáveis.
*   **kubectl:** Ferramenta de linha de comando do Kubernetes.
*   **helm:** Gerenciador de pacotes para Kubernetes.
*   Acesso aos arquivos locais em `kubernetes/networking/traefik/certs/`.

## Cenário 1: O Domínio Virtual Já Está Coberto por um Certificado Wildcard Existente

Este cenário se aplica a `*.local.dev`, coberto pelo certificado criado pelo script local. Domínios fora desse padrão precisam de certificado e Secret próprios, conforme o cenário 2.

### 1. Criar o Manifesto `IngressRoute` para sua Aplicação

Crie um arquivo YAML (ex: `minha-app-ingressroute.yaml`) no repositório da sua aplicação ou em um local centralizado para seus manifestos Kubernetes. Este manifesto instrui o Traefik a rotear o tráfego para o serviço Kubernetes da sua aplicação.

```yaml
# Exemplo: minha-app-ingressroute.yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: minha-app-route
  namespace: default # Ou o namespace onde sua aplicação está rodando
spec:
  entryPoints:
    - websecure # Usa o entrypoint HTTPS do Traefik
  routes:
    - match: Host(`minha-app.local.dev`) # Substitua pelo seu domínio virtual
      kind: Rule
      services:
        - name: meu-app-service # O NOME DO SERVICE KUBERNETES DA SUA APLICAÇÃO
          port: 80 # A PORTA QUE SEU SERVICE KUBERNETES EXPÕE INTERNAMENTE
  tls:
    secretName: local-dev-tls # Referencia o secret TLS já existente do Traefik
```

### 2. Aplicar o Manifesto no Kubernetes

No terminal, no diretório onde você salvou o manifesto acima:

```bash
kubectl apply -f minha-app-ingressroute.yaml
```

### 3. Atualizar seu arquivo `/etc/hosts`

Para que seu navegador consiga resolver o novo domínio para o seu ambiente local, adicione a seguinte entrada ao seu arquivo `/etc/hosts`:

```
127.0.0.1 minha-app.local.dev # Substitua pelo seu domínio virtual
```

## Cenário 2: O Domínio Não Está Coberto pelo Certificado Local

O certificado criado pelo script `setup-mkcert-localdev.sh` cobre `local.dev` e `*.local.dev`. Para um nome fora desse padrão, gere um certificado local adicional e mantenha-o separado. Não concatene certificados e chaves privadas em um único arquivo.

### 1. Gerar um certificado separado

Na raiz do repositório, gere o certificado para o nome que será usado no navegador:

```bash
mkdir -p kubernetes/networking/traefik/certs/extra
mkcert \
  -cert-file kubernetes/networking/traefik/certs/extra/meu-dominio.crt \
  -key-file kubernetes/networking/traefik/certs/extra/meu-dominio.key \
  meu-dominio.test '*.meu-dominio.test'
```

`mkcert -install` precisa ter sido executado neste computador para confiar na autoridade local. O certificado e a chave permanecem ignorados pelo Git.

### 2. Criar um Secret TLS próprio

Use um nome distinto do Secret wildcard `local-dev-tls`:

```bash
kubectl create secret tls meu-dominio-tls \
  --cert=kubernetes/networking/traefik/certs/extra/meu-dominio.crt \
  --key=kubernetes/networking/traefik/certs/extra/meu-dominio.key \
  -n default
```

No `IngressRoute`, use `secretName: meu-dominio-tls`. Para atualizar o certificado depois, substitua o Secret com `kubectl create secret tls ... --dry-run=client -o yaml | kubectl apply -f -`.

### 3. Resolver o domínio localmente

Adicione o nome ao `/etc/hosts`, apontando para o endereço local do cluster. Em um cluster local cujo Traefik publica no host, use:

```text
127.0.0.1 meu-dominio.test
```

Se o cluster expõe o Traefik por outro endereço, use o IP indicado pelo ambiente Kubernetes.

### 4. Criar o Manifesto `IngressRoute` para sua Aplicação

Crie um arquivo YAML (ex: `minha-app-ingressroute.yaml`) no repositório da sua aplicação ou em um local centralizado para seus manifestos Kubernetes.

```yaml
# Exemplo: minha-app-ingressroute.yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: minha-app-route
  namespace: default # Ou o namespace onde sua aplicação está rodando
spec:
  entryPoints:
    - websecure # Usa o entrypoint HTTPS do Traefik
  routes:
    - match: Host(`meu-dominio.test`) # Substitua pelo seu novo domínio virtual
      kind: Rule
      services:
        - name: meu-app-service # O NOME DO SERVICE KUBERNETES DA SUA APLICAÇÃO
          port: 80 # A PORTA QUE SEU SERVICE KUBERNETES EXPÕE INTERNAMENTE
  tls:
    secretName: meu-dominio-tls # Secret criado para este domínio
```

### 5. Aplicar o Manifesto no Kubernetes

No terminal, no diretório onde você salvou o manifesto acima:

```bash
kubectl apply -f minha-app-ingressroute.yaml
```

### 6. Atualizar seu arquivo `/etc/hosts`

Para que seu navegador consiga resolver o novo domínio para o seu ambiente local, adicione a seguinte entrada ao seu arquivo `/etc/hosts`:

```
127.0.0.1 meu-dominio.test # Substitua pelo seu novo domínio virtual
```

## Considerações Finais

*   Sempre verifique os logs do Traefik (`kubectl logs -f <pod-do-traefik>`) se encontrar problemas.
*   Certifique-se de que o nome do serviço (`meu-app-service`) e a porta (`80`) no `IngressRoute` correspondem ao seu serviço Kubernetes real.
*   Lembre-se que `mkcert` gera certificados que expiram. Você precisará renová-los periodicamente.
