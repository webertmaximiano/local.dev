# Trilha Kubernetes

Kubernetes é a trilha avançada deste repositório. O percurso padrão para desenvolver e operar em uma VPS pequena está em [`../infra/swarm/README.md`](../infra/swarm/README.md), usando Docker Swarm. Estude esta trilha quando precisar dos recursos e do ecossistema Kubernetes.

## Ordem sugerida

1. **Cluster e kubectl:** prepare um cluster local e aprenda contextos, namespaces e comandos em [`cluster/`](cluster/).
2. **Workloads:** estude Pods como unidade básica e use Deployments para aplicações stateless; avance para StatefulSets e Jobs conforme o tipo de carga. Os exemplos ficam em [`workloads/`](workloads/).
3. **Rede de entrada:** configure Services, Ingress e Traefik em [`networking/traefik/`](networking/traefik/).
4. **Dados e estado:** pratique PVCs e os exemplos de MySQL, PostgreSQL e Redis em [`workloads/databases/`](workloads/databases/).
5. **Observabilidade:** configure Prometheus e Grafana em [`observability/prometheus-grafana/`](observability/prometheus-grafana/).
6. **Ferramentas de gestão:** veja o exemplo de Portainer em [`tools/portainer/`](tools/portainer/).

## Kubernetes depois do Swarm

Imagens OCI, código da aplicação, configuração externa, logs em stdout/stderr e endpoints de saúde podem ser aproveitados nos dois ambientes. Os arquivos de orquestração não são intercambiáveis: serviços e stacks Swarm precisam ser traduzidos para recursos Kubernetes, como Deployments, Services, Ingress, Secrets e PVCs. Planeje separadamente a migração de dados e volumes.

Um Pod direto é útil para aprender e depurar; aplicações que precisam continuar disponíveis devem ser geridas por um controlador, normalmente Deployment para workloads stateless. Consulte a [documentação de Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

Kubernetes não adiciona capacidade física por si só nem é um passo obrigatório para escalar. Primeiro identifique a necessidade operacional; Swarm também distribui tarefas entre nós e permite escalar réplicas. A documentação do Docker descreve [serviços, placement e escala no Swarm](https://docs.docker.com/engine/swarm/services/).

## Isolamento e segurança

- Não inicie o Traefik Kubernetes e o Traefik Swarm simultaneamente se ambos precisarem das portas 80/443.
- Não versione credenciais, certificados ou arquivos locais de configuração. Use Secrets e mantenha os valores fora do Git.
- Os manifestos desta trilha são exemplos didáticos; revise imagens, recursos, storage e controles de acesso antes de qualquer uso compartilhado ou produção.
