# Tutorial: Docker Swarm local

Este guia usa o laboratório genérico deste repositório. Os comandos `make` gerenciam somente as stacks do laboratório; não iniciam nem removem aplicações de outros diretórios.

## 1. Conceitos e requisitos

Tenha Docker Engine, Docker Compose plugin e GNU Make instalados. O laboratório usa Swarm de nó único, Traefik como proxy HTTPS central e Portainer opcional. Um nó permite praticar stacks, serviços, redes, secrets e réplicas, mas réplicas compartilham CPU, memória e disco da mesma máquina; para aprender distribuição real, adicione outro nó Linux ao Swarm.

Confira `make help` e siga [`../infra/swarm/README.md`](../infra/swarm/README.md) para preparar certificados e nomes locais. O alvo `make up` inicializa o Swarm caso necessário e publica somente o Traefik. `make portainer-up` publica Portainer separadamente.

## 2. Redes, stacks e roteamento

O laboratório cria as redes overlay `web-local` e `monitoring`; Portainer cria também `portainer_agent_network`. O Traefik usa o provider Swarm, portanto aplicações roteadas devem ser serviços em uma stack Swarm, estar conectadas à rede externa `web-local` e declarar labels dentro de `deploy.labels`.

Exemplo mínimo de stack para uma aplicação que escuta na porta 8080:

```yaml
services:
  app:
    image: nginx:alpine
    networks:
      - web-local
    deploy:
      replicas: 1
      labels:
        - traefik.enable=true
        - traefik.swarm.network=web-local
        - traefik.http.routers.exemplo.rule=Host(`exemplo.local.dev`)
        - traefik.http.routers.exemplo.entrypoints=websecure
        - traefik.http.routers.exemplo.tls=true
        - traefik.http.services.exemplo.loadbalancer.server.port=80

networks:
  web-local:
    external: true
```

Cadastre `127.0.0.1 exemplo.local.dev` em `/etc/hosts` e publique a stack com `docker stack deploy -c stack.yml exemplo`. O container precisa escutar na porta declarada; não publique portas no host quando o acesso será pelo Traefik.

## 3. Escalar, atualizar e inspecionar

```bash
docker service scale exemplo_app=2
docker service update --image nginx:alpine exemplo_app
docker service update --rollback exemplo_app
docker service ps exemplo_app
docker service logs --follow exemplo_app
```

Ajuste `deploy.resources` e placement à capacidade disponível. Escalar para duas réplicas no Swarm local não acrescenta capacidade física.

## 4. Ciclo de vida das stacks de infraestrutura

```bash
make status
make portainer-down
make traefik-down
```

`make portainer-down` e `make traefik-down` removem apenas a stack correspondente. Os volumes persistentes são mantidos. Não use `docker system prune` como rotina para liberar espaço: primeiro identifique imagens, volumes e dados que podem ser removidos.

## 5. Segurança operacional

- Não versione `.env`, senhas, tokens, chaves privadas, certificados gerados ou backups.
- O Makefile cria o BasicAuth do dashboard como Docker Secret e solicita a senha no terminal; nunca coloque a senha em um comando ou arquivo versionado.
- O socket Docker concede controle elevado sobre o host, inclusive quando montado como somente leitura. Limite quem pode acessar o daemon e o Portainer.
- Mantenha o laboratório local; não exponha dashboard, Portainer ou portas de administração à Internet.
