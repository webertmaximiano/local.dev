# Infraestrutura local com Docker Swarm

Este ambiente é genérico para estudo e desenvolvimento; não contém comandos de projetos privados. O objetivo é praticar, em um Swarm de um nó, proxy, redes, secrets, serviços e stacks como numa VPS.

## Stacks e consumo

- **Traefik:** stack base, única dona das portas 80/443.
- **Portainer + Agent:** opcional; ligue apenas para praticar a interface de gerenciamento.
- **Bancos e monitoramento:** serviços opcionais, adicionados em stacks próprias quando o curso precisar deles.

Cada stack tem diretório e ciclo de vida próprios. O Makefile não inicia tudo de uma vez nem para containers de outros projetos.

## Requisitos

Docker Engine com Swarm, GNU Make, `mkcert` e `htpasswd` (`apache2-utils` no Debian/Ubuntu). Confira se as portas 80/443 estão livres. Se já houver um Traefik local, atualize essa instância em vez de iniciar outra.

## Preparar e iniciar

Execute os comandos sempre na raiz deste repositório. Os manifests vivem nas pastas de cada stack, mas o Makefile central controla o ciclo de vida:

```bash
make help
make tls-setup
```

O alvo `tls-setup` instala a CA local no trust store usando mkcert e gera um wildcard. Em seguida, edite `/etc/hosts` (Linux: `sudoedit /etc/hosts`) com os nomes que usará:

```text
127.0.0.1 traefik.local.dev
127.0.0.1 portainer.local.dev
127.0.0.1 whoami.local.dev
```

Inicie somente o proxy central:

```bash
make traefik-up
```

Na primeira execução, o Makefile inicializa o Swarm se necessário, cria a rede `web-local` (overlay attachable) e garante a rede overlay `monitoring`, solicita a credencial BasicAuth do dashboard e publica a stack Traefik. O login do dashboard é independente do Portainer; para trocar a senha BasicAuth, use `make traefik-secret-rotate`. Acesse `https://traefik.local.dev`.

Portainer é opcional. O alvo verifica se o Traefik está saudável e só o inicia se estiver ausente ou sem réplica ativa; com o proxy saudável, preserva a stack atual:

```bash
make portainer-up
```

Consulte o [guia de Portainer](portainer/README.md) para aprender quando usar a interface, exercícios de inspeção e os cuidados de segurança. Para desligá-lo sem apagar os dados persistidos, use `make portainer-down`; o Traefik continua ativo. `make traefik-down` para o proxy e interrompe as rotas locais. Esses alvos removem apenas serviços das stacks: não apagam volumes Docker nem os certificados locais. O volume externo `portainer_data` continua disponível quando Portainer estiver desligado.

## Aplicações de exemplo

Esta trilha usa o provider Swarm do Traefik. Portanto, os exemplos roteados devem ser serviços Swarm, conectados à rede externa `web-local`, com labels em `deploy.labels` e porta interna declarada. Consulte [`traefik/README.md`](traefik/README.md).

Um Swarm de nó único ensina `docker stack deploy`, `docker service scale`, labels e redes; réplicas extras continuam usando CPU e memória do mesmo computador.

## Operação

```bash
make status
make logs-traefik
make portainer-down
make traefik-down
```

Os alvos `*-down` removem apenas a stack nomeada e preservam os volumes. Não há um alvo que pare containers alheios ao laboratório.
