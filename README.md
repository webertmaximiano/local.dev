# Agilizando o Futuro: Docker Swarm e Kubernetes

Este repositório ensina desenvolvimento e operação de aplicações em contêineres, começando por um laboratório Docker Swarm simples e avançando para Kubernetes. O [guia de aprendizagem](./Guia_de_Aprendizado_Agilizando_o_Futuro.md) apresenta a sequência dos estudos.

## Caminho recomendado: Docker Swarm local

O laboratório principal está em [`infra/swarm/`](./infra/swarm/). Ele oferece um Traefik central e stacks opcionais, controladas por comandos explícitos na raiz: `make traefik-up`, `make portainer-up`, `make monitoring-up` e seus alvos `down`. Veja [`make help`](./Makefile) e o [guia do laboratório](./infra/swarm/README.md).

Uma VPS pequena pode começar com um nó Swarm. O Swarm também suporta vários nós e réplicas distribuídas. Um Swarm local de um nó ajuda a aprender o fluxo, mas não simula disponibilidade entre máquinas.

## Trilha avançada: Kubernetes

Os tutoriais, manifests e aplicações didáticas Kubernetes estão organizados em [`kubernetes/`](./kubernetes/README.md):

- `cluster/`: cluster local e kubectl;
- `workloads/`: exemplos, bancos e armazenamento;
- `networking/traefik/`: Ingress e domínios;
- `observability/prometheus-grafana/`: métricas e dashboards;
- `tools/portainer/`: exemplo de gestão visual.

Kubernetes é uma opção para requisitos que justifiquem sua complexidade operacional. Imagens e práticas de aplicação podem ser compartilhadas com Swarm; os manifests de cada orquestrador exigem configuração própria.

## Outras trilhas

- [`docker/`](./docker/): Docker Engine, Compose e exemplos;
- [`docker/examples/mysql/compose.yml`](./docker/examples/mysql/compose.yml): exemplo Compose separado do laboratório Swarm;
- [`git-github/`](./git-github/): Git e GitHub;
- [`vscode/`](./vscode/): editor e ferramentas;
- [`ci-cd-automation/`](./ci-cd-automation/): CI/CD e GitOps;
- [`volumes/`](./volumes/): desenvolvimento e sincronização de arquivos.

## Começar

Clone o repositório e veja os alvos disponíveis: `make help`. Para preparar o ambiente Swarm, siga [`infra/swarm/README.md`](./infra/swarm/README.md). Para estudar Kubernetes depois, siga [`kubernetes/README.md`](./kubernetes/README.md). Não suba dois proxies locais que disputem as portas 80/443 ao mesmo tempo.
