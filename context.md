Estamos configurando um ambiente de desenvolvimento e produzindo tutoriais do passo a passo do caminho feliz, somente do que deu certo para orientar os alunos.

Já temos Ubuntu 24, Docker e Docker Desktop instalados. Habilitamos o Kubernetes via Docker Desktop, instalamos o Traefik e criamos o tutorial na pasta `traefik`, expondo a dashboard em `traefik.local.dev`.

Configuramos Prometheus e Grafana com acesso em `prometheus.local.dev` e `grafana.local.dev`, incluindo uma dashboard no Grafana para monitorar o Traefik. Há pastas `mysql` e `pgsql` com deployments exemplo para esses serviços, e um tutorial para subir uma aplicação local `hello-world-app`.

### Status atual

- Kubernetes local pelo Docker Desktop: funcionando
- Traefik no cluster: funcionando
- Portainer Server no Kubernetes: implantado e acessível em `https://portainer.local.dev`
- Portainer Agent: rodando como serviço Docker Swarm global no host
- Endpoint do Agent no Portainer: `https://host.docker.internal:9001`

### Direção atual

Queremos manter o tutorial focado no fluxo Kubernetes, com:

- `Portainer Server` no cluster Kubernetes
- `Traefik` como Ingress Controller
- `Portainer Agent` no Docker Desktop para conectar o Portainer ao Docker local

### O que foi validado

- Tutorial do Portainer atualizado em `portainer/tutorial-portainer-kubernetes.md`
- Agent Swarm criado e rodando corretamente
- Serviços accesíveis localmente e via Cluster
- Push final feito para `origin main`

### Observações para alunos

- O Portainer do Kubernetes gerencia Kubernetes por padrão.
- Para gerenciar o Docker local, conecta-se a um endpoint Agent, não a outro Portainer Server.
- Usar `host.docker.internal` no endpoint Agent quando o Portainer está dentro do cluster Docker Desktop.

# cluster
- Docker Desktop
- Kubernetes local no Docker Desktop
- Swarm ativo para o Agent Docker

# Traefik, Prometheus e Grafana com Kubernetes
- Funcionando
- Configuração feita com Helm

# teste sempre
Após realizar as configurações, use `curl` e verifique se consegue acessar as dashboards:
- `https://traefik.local.dev`
- `https://portainer.local.dev`

# plano de ação
- manter o tutorial enxuto e focado em Kubernetes
- documentar corretamente o fluxo do Agent Docker local
- revisar README e Guia de Aprendizado se necessário
- validar todos os endpoints com `curl`
