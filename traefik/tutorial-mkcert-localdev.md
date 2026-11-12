# HTTPS local com mkcert e Traefik

Para o ambiente Docker Swarm deste repositório, siga o tutorial canônico em [`traefik_portainer/README.md`](../traefik_portainer/README.md). Ele ensina o Traefik central, o wildcard `*.local.dev`, os hosts `servico.local.dev`, a autenticação do dashboard e o deploy.

Este diretório também contém a trilha separada de Traefik para Kubernetes. Não inicie essa trilha e a stack Swarm ao mesmo tempo nas mesmas portas 80/443.

## Regras para certificados locais

- `mkcert -install` instala uma CA confiável apenas no computador atual.
- Gere o wildcard `*.local.dev` localmente. Não versione os certificados nem as chaves privadas.
- `/etc/hosts` não aceita wildcard. Cadastre cada hostname ou configure DNS local wildcard.
- Nunca copie a chave raiz privada do `mkcert` para o repositório ou para outros computadores.

Consulte a [documentação oficial do mkcert](https://github.com/FiloSottile/mkcert) e a [documentação TLS do Traefik](https://doc.traefik.io/traefik/https/).
