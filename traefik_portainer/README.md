# Traefik local e Portainer no Docker Swarm

Este é o caminho canônico deste repositório para estudar e operar Traefik com Docker Swarm. Existe **uma instância central do Traefik** no ambiente local; cada projeto se conecta à rede externa `web-local` e declara suas rotas por labels.

Os manifests em `../traefik/` são uma trilha separada para Kubernetes. Não suba os dois ambientes ao mesmo tempo nas mesmas portas.

## Domínios e HTTPS local

Padronize os endereços como `servico.local.dev`: `traefik.local.dev`, `portainer.local.dev` e `meuprojeto.local.dev`. O certificado `*.local.dev` cobre esses hosts de um nível. O arquivo `/etc/hosts` não aceita curingas; adicione uma entrada para cada projeto:

```text
127.0.0.1 traefik.local.dev
127.0.0.1 portainer.local.dev
127.0.0.1 meuprojeto.local.dev
```

Instale `mkcert` conforme as instruções para seu sistema operacional na [documentação oficial](https://github.com/FiloSottile/mkcert), depois instale a CA local uma vez por computador. A CA deve ser confiável pelo sistema e pelo navegador que você usa:

```bash
mkcert -install
mkdir -p traefik_portainer/certs/local.dev
mkcert -cert-file traefik_portainer/certs/local.dev/local.dev.fullchain.crt \
  -key-file traefik_portainer/certs/local.dev/local.dev.key \
  "*.local.dev" local.dev
```

Os certificados e chaves ficam ignorados pelo Git. Gere-os em cada máquina. Nunca versione nem compartilhe a chave privada da CA do `mkcert`.

## Requisitos e portas

- Docker Engine com Swarm habilitado em um manager local.
- Portas `80` e `443` livres. Esta stack é o proxy central e deve ser a única instância local do Traefik que publica essas portas.
- `htpasswd` (`apache2-utils` no Debian/Ubuntu) para criar a credencial do dashboard.

Confira antes de iniciar. Se já existir um Traefik usando as portas, reaproveite essa instância e atualize a stack; não inicie outra em paralelo.

```bash
docker info --format '{{.Swarm.LocalNodeState}}'
docker service ls
```

Se o Swarm ainda não estiver inicializado:

```bash
docker swarm init
```

## Criar recursos e credencial

Execute os comandos a partir da raiz do repositório. Crie redes e volumes uma vez; se já existirem, não os recrie:

```bash
docker network create --driver overlay --attachable web-local
docker network create --driver overlay --attachable monitoring
docker network create --driver overlay --attachable portainer_agent_network
docker volume create portainer_data
```

Crie o Docker Secret do usuário do dashboard. O comando solicita a senha sem colocá-la em um arquivo do repositório:

```bash
htpasswd -nB localadmin | docker secret create traefik_dashboard_users -
```

O secret do Swarm é lido pelo middleware BasicAuth. Para trocar a credencial, remova e recrie o secret e atualize a stack durante uma janela de manutenção; secrets Swarm são imutáveis.

## Subir as stacks

A stack monta arquivos por caminhos relativos. Entre na pasta antes de fazer o deploy:

```bash
cd traefik_portainer
docker stack deploy -c compose-traefik-swarm.yml traefik
docker stack deploy -c compose-portainer-swarm.yml portainer
```

A imagem do Traefik está fixada em `v3.7.18`. O dashboard fica em `https://traefik.local.dev` e exige a credencial criada acima. O Portainer fica em `https://portainer.local.dev` e pede a criação do administrador no primeiro acesso.

## Conectar um projeto ao Traefik

O serviço da aplicação precisa se conectar à rede externa `web-local`. Exemplo para um container que escuta na porta interna `8000`:

```yaml
services:
  app:
    image: minha-aplicacao:dev
    networks:
      - web-local
    deploy:
      labels:
        - traefik.enable=true
        - traefik.swarm.network=web-local
        - traefik.http.routers.meuprojeto.rule=Host(`meuprojeto.local.dev`)
        - traefik.http.routers.meuprojeto.entrypoints=websecure
        - traefik.http.routers.meuprojeto.tls=true
        - traefik.http.services.meuprojeto.loadbalancer.server.port=8000

networks:
  web-local:
    external: true
```

No provider Swarm do Traefik v3, as labels de roteamento ficam em `deploy.labels`. Ajuste a porta para a porta interna real da aplicação. Não publique a porta da aplicação no host se o acesso será feito pelo Traefik.

## Verificar e parar

```bash
docker stack services traefik
docker stack services portainer
docker service logs -f traefik_traefik
```

Para remover as stacks sem apagar redes, volumes do Portainer ou secrets:

```bash
docker stack rm portainer
docker stack rm traefik
```

## Segurança e limites

- O provider Swarm precisa consultar a API do Docker. Montar `docker.sock` como `:ro` protege o arquivo contra escrita direta, mas **não torna a API somente leitura**. Considere esse acesso privilegiado ao daemon.
- O dashboard usa BasicAuth e o Docker Secret, e as métricas não são publicadas numa porta do host. Mantenha as portas 80/443 acessíveis apenas pela rede local.
- Portainer tem autenticação própria. Não exponha esta stack à internet como está.
- O Swarm de nó único permite estudar labels e deploy, mas não simula alta disponibilidade nem falha de um manager.

## Trilha Kubernetes

Para estudar Traefik como Ingress Controller no Kubernetes, use os tutoriais e manifests em `../traefik/` e `../kubernetes/`. É outro ambiente; não o inicie ao mesmo tempo que esta stack nas mesmas portas HTTP/HTTPS.
