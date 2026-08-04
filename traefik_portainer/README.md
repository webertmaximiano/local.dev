# Docker Swarm com Traefik e Portainer

Este diretório documenta o fluxo de implantação em Docker Swarm usando:

- `compose-traefik-swarm.yml` — stack do Traefik
- `compose-portainer-swarm.yml` — stack do Portainer + Portainer Agent

## Pré-requisitos

1.  **Docker** instalado.
2.  **Docker Swarm** inicializado.
3.  **Entradas no `/etc/hosts`:**

    ```bash
    127.0.0.1 traefik.local.dev
    127.0.0.1 portainer.local.dev
    ```

## Criar certificados locais

Antes de subir o Traefik, gere os certificados locais no diretório de `certs` usando `mkcert`:

```bash
cd traefik_portainer/certs/local.dev
mkcert -install
mkcert -cert-file local.dev.fullchain.crt -key-file local.dev.key "*.local.dev" traefik.local.dev portainer.local.dev 127.0.0.1 ::1
```

Isso garante que os arquivos usados pelo Traefik sejam assinados pela CA local do seu host.

## 1. Inicializar o Swarm

Se o Swarm ainda não estiver ativo:

```bash
docker swarm init
```

## 2. Criar as redes overlay necessárias

```bash
docker network create --driver overlay --attachable web-local
docker network create --driver overlay --attachable monitoring
docker network create --driver overlay --attachable portainer_agent_network
```

## 3. Criar o volume do Portainer

```bash
docker volume create portainer_data
```

## 4. Deploy do Traefik no Swarm

```bash
cd traefik_portainer
docker stack deploy -c compose-traefik-swarm.yml traefik
```

## 5. Deploy do Portainer + Agent

```bash
docker stack deploy -c compose-portainer-swarm.yml portainer
```

## Acessando

Após o deploy, acesse:

- `https://traefik.local.dev`
- `https://portainer.local.dev`

## TLS / Certificados

O Traefik Swarm monta os certificados locais em:

```yaml
- "./certs/local.dev:/certs:ro"
```

O arquivo dinâmico de TLS (`config/traefik/tls.yml`) deve apontar para:

```yaml
tls:
  certificates:
    - certFile: "/certs/local.dev.fullchain.crt"
      keyFile: "/certs/local.dev.key"
```

O caminho feliz é gerar os certificados localmente com `mkcert` (veja a seção acima). Isso garante que o certificado seja assinado pela CA local do seu computador.

Se ainda receber `ERR_CERT_AUTHORITY_INVALID`, importe a CA local no sistema:

```bash
sudo cp traefik_portainer/certs/local.dev/rootCA.pem /usr/local/share/ca-certificates/local-dev-rootCA.crt
sudo update-ca-certificates
```

Se o erro persistir, regenere os certificados novamente no host atual com `mkcert`.


