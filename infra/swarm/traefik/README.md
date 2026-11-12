# Traefik central no Docker Swarm

Esta stack é o proxy central do laboratório. Ela usa o provider Swarm; aplicações roteadas por ela precisam ser serviços Swarm conectados à rede overlay externa `web-local`.

## Domínios e HTTPS

Use hosts de um nível como `traefik.local.dev`, `portainer.local.dev` e `whoami.local.dev`. O certificado `*.local.dev` cobre esses nomes. `/etc/hosts` não aceita curingas: cadastre cada hostname ou configure um DNS local wildcard.

Na raiz do repositório, `make tls-setup` instala a CA local com mkcert e gera os arquivos ignorados pelo Git em `infra/swarm/traefik/certs/local.dev/`. O nome `local.dev.fullchain.crt` é legado: o arquivo contém o certificado do host; a CA raiz é confiada separadamente.

## Subir o Traefik

```bash
make traefik-up
```

O Makefile inicializa o Swarm se necessário, cria as redes externas `web-local` e `monitoring`, cria o Docker Secret `traefik_dashboard_users_v2` se ainda não existir e faz deploy da stack. `htpasswd` solicita a senha sem salvá-la no repositório.

Acesse `https://traefik.local.dev`. Para Portainer, use `make portainer-up` e o guia em [`../portainer/README.md`](../portainer/README.md).

## Roteamento de uma aplicação Swarm

O serviço precisa conectar-se à rede externa e receber as labels em `deploy.labels`. Exemplo para uma aplicação que escuta na porta interna 8080:

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
        - traefik.http.routers.whoami.rule=Host(`whoami.local.dev`)
        - traefik.http.routers.whoami.entrypoints=websecure
        - traefik.http.routers.whoami.tls=true
        - traefik.http.services.whoami.loadbalancer.server.port=8080

networks:
  web-local:
    external: true
```

No Swarm, Traefik lê labels do serviço em `deploy.labels`, e a porta interna deve ser declarada. Não publique a porta do app no host se o acesso será pelo proxy. [Documentação oficial do provider Swarm](https://doc.traefik.io/traefik/reference/install-configuration/providers/swarm/).

## Segurança e limites

- O dashboard usa BasicAuth e Docker Secret. O usuário padrão criado pelo laboratório é `admin`; a senha é definida no terminal. O popup do navegador não troca a credencial no servidor: para trocar a senha ou se você não lembra a atual, execute `make traefik-secret-rotate` na raiz. O comando solicita a nova senha sem exibi-la, cria a próxima versão do Secret e reaplica somente o Traefik. Confirme o login e o serviço saudável antes de remover manualmente o Secret antigo com `docker secret rm NOME_ANTIGO`. Nunca remova a versão antiga antes da validação.
- O socket Docker continua sendo acesso privilegiado ao daemon mesmo montado `:ro`.
- Swarm de um nó não distribui carga para outro computador nem oferece alta disponibilidade.
- Esta configuração é para desenvolvimento; não a exponha à Internet.
