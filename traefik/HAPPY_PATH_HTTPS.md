# HTTPS local

Para Docker Swarm, use o guia canônico [`infra/swarm/traefik/README.md`](../infra/swarm/traefik/README.md) e `make tls-setup`.

Os manifests desta pasta pertencem à trilha Kubernetes. Mantenha-a separada da stack Swarm para evitar dois proxies nas portas 80/443.
