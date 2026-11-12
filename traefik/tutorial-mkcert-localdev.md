# HTTPS local com mkcert e Traefik

Siga o tutorial canônico em [`infra/swarm/traefik/README.md`](../infra/swarm/traefik/README.md) e use `make tls-setup` para preparar a CA local e o certificado wildcard.

A pasta `/traefik` contém a trilha Kubernetes, separada da stack Swarm em `/infra/swarm/traefik`. Não inicie os dois proxies ao mesmo tempo nas portas 80/443.

Consulte a [documentação oficial do mkcert](https://github.com/FiloSottile/mkcert). Nunca versione nem compartilhe a chave privada `rootCA-key.pem`.
