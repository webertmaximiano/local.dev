# Guia: Adicionando Novos Domínios Virtuais ao Traefik no Kubernetes

Este guia detalha como adicionar novos domínios virtuais ao seu ambiente Traefik no Kubernetes, garantindo que o HTTPS funcione corretamente. O processo varia ligeiramente dependendo se o novo domínio já está coberto por um certificado wildcard existente.

## Pré-requisitos

*   **mkcert:** Para gerar certificados SSL/TLS locais confiáveis.
*   **kubectl:** Ferramenta de linha de comando do Kubernetes.
*   **helm:** Gerenciador de pacotes para Kubernetes.
*   Acesso ao diretório `/home/webert/local.dev/traefik/certs/`.

## Cenário 1: O Domínio Virtual Já Está Coberto por um Certificado Wildcard Existente

Este cenário se aplica se você está adicionando um subdomínio de um wildcard que já está incluído no seu certificado principal (ex: `minha-app.local.dev` se você já tem `*.local.dev`, ou `api.estouon.dev` se você já tem `*.estouon.dev`).

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

## Cenário 2: O Novo Domínio Virtual NÃO Está Coberto por um Certificado Wildcard Existente

Este cenário se aplica se você está adicionando um domínio completamente novo (ex: `meu-novo-dominio.com`) ou um domínio que não é um subdomínio de um wildcard já existente no seu `cert.pem` (ex: `estouon.dev` se você só tinha `*.local.dev`).

### 1. Gerar os Novos Certificados

Execute `mkcert` no diretório `/home/webert/local.dev/traefik/certs/` para gerar os certificados para o seu novo domínio e seus subdomínios (se aplicável).

```bash
cd /home/webert/local.dev/traefik/certs/
mkcert meu-novo-dominio.com *.meu-novo-dominio.com # Substitua pelo seu novo domínio
```
Anote os nomes exatos dos arquivos `.pem` e `-key.pem` gerados (ex: `meu-novo-dominio.com+1.pem` e `meu-novo-dominio.com+1-key.pem`).

### 2. Concatenar os Novos Certificados aos Arquivos Existentes

Adicione o conteúdo dos novos arquivos `.pem` e `-key.pem` aos seus arquivos `cert.pem` e `privkey.pem` existentes.

```bash
cat /home/webert/local.dev/traefik/certs/meu-novo-dominio.com+1.pem >> /home/webert/local.dev/traefik/certs/cert.pem
cat /home/webert/local.dev/traefik/certs/meu-novo-dominio.com+1-key.pem >> /home/webert/local.dev/traefik/certs/privkey.pem
```
Substitua os nomes dos arquivos pelos que foram gerados no passo anterior.

### 3. Recriar o Secret TLS no Kubernetes

Agora que os arquivos `cert.pem` e `privkey.pem` estão atualizados, precisamos recriar o secret `local-dev-tls` no Kubernetes para que ele use os novos certificados.

```bash
kubectl delete secret local-dev-tls --ignore-not-found
kubectl create secret tls local-dev-tls --cert=/home/webert/local.dev/traefik/certs/cert.pem --key=/home/webert/local.dev/traefik/certs/privkey.pem -n default
```

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
    - match: Host(`meu-novo-dominio.com`) # Substitua pelo seu novo domínio virtual
      kind: Rule
      services:
        - name: meu-app-service # O NOME DO SERVICE KUBERNETES DA SUA APLICAÇÃO
          port: 80 # A PORTA QUE SEU SERVICE KUBERNETES EXPÕE INTERNAMENTE
  tls:
    secretName: local-dev-tls # Referencia o secret TLS já existente do Traefik
```

### 5. Aplicar o Manifesto no Kubernetes

No terminal, no diretório onde você salvou o manifesto acima:

```bash
kubectl apply -f minha-app-ingressroute.yaml
```

### 6. Atualizar seu arquivo `/etc/hosts`

Para que seu navegador consiga resolver o novo domínio para o seu ambiente local, adicione a seguinte entrada ao seu arquivo `/etc/hosts`:

```
127.0.0.1 meu-novo-dominio.com # Substitua pelo seu novo domínio virtual
```

## Considerações Finais

*   Sempre verifique os logs do Traefik (`kubectl logs -f <pod-do-traefik>`) se encontrar problemas.
*   Certifique-se de que o nome do serviço (`meu-app-service`) e a porta (`80`) no `IngressRoute` correspondem ao seu serviço Kubernetes real.
*   Lembre-se que `mkcert` gera certificados que expiram. Você precisará renová-los periodicamente.
