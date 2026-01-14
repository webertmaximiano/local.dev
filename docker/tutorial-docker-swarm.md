````markdown
# Tutorial Rápido: Docker Swarm — Iniciando localmente (modo manager)

Este tutorial mostra os passos básicos para iniciar um ambiente Docker Swarm local, criar redes/volumes/secrets, definir recursos e subir stacks (útil para aprendizado e testes locais como manager).

**Pré-requisitos**
- Docker instalado e usuário com permissão para usá-lo.
- Acesso ao nó que será manager (máquina local no passo a passo).

## 1) Inicializar o Swarm (no manager)

```bash
# inicializa o swarm no nó atual (substitua IP se necessário)
docker swarm init --advertise-addr 127.0.0.1

# ver o token para adicionar workers
docker swarm join-token worker
```

Anote o comando `docker swarm join --token ...` para adicionar nós workers.

## 2) Criar redes overlay, volumes e secrets

```bash
# redes (overlay) que o Traefik e Portainer usam
# usar --attachable em ambientes de desenvolvimento para conectar containers "normais"
docker network create --driver overlay --attachable traefik-public
docker network create --driver overlay --attachable portainer_agent_network
docker network create --driver overlay --attachable monitoring

# volumes/dirs necessários
# volume para persistência do Portainer
docker volume create portainer_data

# volume para logs do Traefik (o stack usa 'traefik_logs' como volume externo)
docker volume create traefik_logs

# criar secret (exemplo: senha ou certificado)
echo "minha-senha-secreta" | docker secret create portainer_admin_password -

# listar
docker network ls
docker volume ls
docker secret ls
```

## 3) Escrever/entender `docker-compose` / stack para Swarm

No Swarm usamos `deploy:` dentro do compose para controlar réplicas, placement e recursos.

Exemplo mínimo (snippet):

```yaml
version: '3.8'
services:
  app:
    image: nginx:alpine
    networks:
      - traefik-public
    deploy:
      replicas: 2
      placement:
        constraints: [node.platform.os == linux]
      resources:
        limits:
          cpus: '0.50'
          memory: 200M
        reservations:
          cpus: '0.25'
          memory: 100M

networks:
  traefik-public:
    external: true
```

Coloque o ficheiro de stack (ex: `compose-portainer-swarm.yml` e `compose-traefik-swarm.yml`) no diretório e use `docker stack deploy`.

## 4) Deploy do stack

```bash
# deploy Traefik (stack separado)
docker stack deploy -c traefik_portainer/compose-traefik-swarm.yml traefik

# deploy Portainer + Agent
docker stack deploy -c traefik_portainer/compose-portainer-swarm.yml portainer
```

Verificações:

```bash
docker stack ls
docker stack services portainer
docker service ls
docker service ps portainer_portainer
```

## 5) Atualizar, escalar, remover

```bash
# escalar um serviço (ex: 3 réplicas)
docker service update --replicas 3 portainer_portainer

# atualizar imagem
docker service update --image portainer/portainer-ce:2.33.1 portainer_portainer

# rollback se necessário
docker service update --rollback portainer_portainer

# remover stack
docker stack rm portainer
```

## 6) Boas práticas e dicas rápidas
- Use `deploy.resources` para reservar/limitar CPU e memória.
- Use `placement.constraints` para forçar serviços apenas em managers ou nodes linux.
- Separe stacks: Traefik em um stack próprio facilita updates e segurança.
- Proteja o dashboard do Traefik (IP allow list, TLS, basic auth) — não deixe em aberto na internet.
- Não armazene secrets em arquivos de texto; use `docker secret`.

## 7) Exemplo prático (Portainer + Agent + Traefik)

- Já temos exemplos neste repositório:
  - `traefik_portainer/compose-traefik-swarm.yml`
  - `traefik_portainer/compose-portainer-swarm.yml`

Siga a ordem: criar redes/volumes/secrets → deploy Traefik → deploy Portainer. Ajuste as labels `Host(...)` para o domínio local ou real que for usar (ex: `portainer.local.dev` ou `portainer.corridajusta.com.br`).

## 8) Comandos úteis de debug

```bash
docker node ls
docker service logs --follow <service>
docker inspect <service|network|volume>
docker stack ps <stack>
```

---

Se quiser, eu posso:
- gerar um arquivo de exemplo adicional com comentários; ou
- executar os comandos (criar redes/volumes) neste host — quer que eu faça isso agora?

````
