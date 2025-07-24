# Guia Agilizando o Futuro: Do Zero à Nuvem com Kubernetes e Docker

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white) ![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white) ![Traefik](https://img.shields.io/badge/Traefik-9D61E1?style=for-the-badge&logo=traefikmesh&logoColor=white) ![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white) ![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)

Este não é apenas um repositório de código. É o seu **guia prático e completo** para dominar as tecnologias de nuvem e DevOps que o mercado de trabalho exige.

Criado como a espinha dorsal do projeto social **Agilizando o Futuro**, este guia foi desenhado para levar desenvolvedores(as) do conhecimento zero em contêineres até a orquestração de aplicações complexas em Kubernetes, tudo de forma prática e no seu próprio computador.

### Para Quem é Este Guia?
* Para desenvolvedores que querem dar o próximo passo na carreira e aprender DevOps.
* Para estudantes de tecnologia que buscam experiência prática além da faculdade.
* Para profissionais que desejam entender e implementar Kubernetes em seus próprios projetos.

---

### 🛠️ Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas, de acordo com o caminho que deseja seguir:
* **Para ambos os ambientes:**
    * Git
    * Docker
* **Apenas para o ambiente Kubernetes:**
    * kubectl
    * Um cluster Kubernetes local (ex: habilitado no Docker Desktop, ou usando K3s).

---

### 📂 Estrutura do Repositório

Este repositório está organizado da seguinte forma:

* **`Guia_de_Aprendizado_Agilizando_o_Futuro.md`**: O documento central que guia toda a sua jornada de aprendizado.
* **`/git-github`**: Tutoriais e exemplos para Git e GitHub.
* **`/vscode`**: Tutoriais e configurações para o Visual Studio Code.
* **`/docker`**: Tutoriais de instalação e uso do Docker e Docker Desktop.
* **`/ci-cd-automation`**: Tutoriais e exemplos para CI/CD e GitOps.

**Ambiente Kubernetes**
* **`/kubernetes`**: Contém guias e utilitários gerais sobre Kubernetes.
* **`/kubernetes-dashboard`**: Arquivos para implantar o Dashboard oficial do Kubernetes.
* **`/monitoring`**: Configurações e tutorial para o stack de monitoramento com Prometheus e Grafana.
* **`/mysql`**: Manifesto e [tutorial](./mysql/tutorial-subindo-o-mysql.md) para implantar um servidor MySQL no Kubernetes.
* **`/redis`**: Manifesto e [tutorial](./redis/tutorial-subindo-o-redis.md) para implantar um servidor Redis no Kubernetes.
* **`/pgsql`**: Manifesto para implantar um servidor PostgreSQL no Kubernetes.
* **`/traefik`**: Arquivos de configuração e tutorial para usar o Traefik como Ingress Controller no Kubernetes **e como reverse proxy para contêineres Docker**.

**Ambiente Docker Compose/Swarm (Alternativo)**
* **`/traefik_portainer`**: Contém uma configuração completa com `docker-compose.yml` para rodar o Traefik como reverse proxy e o Portainer como interface de gerenciamento do Docker. **Esta opção é ideal para quem busca um ambiente robusto sem a complexidade inicial do Kubernetes, ou como uma alternativa ao Traefik do Kubernetes para gerenciar apenas contêineres Docker.**

---
## 📚 Guias e Tutoriais

Para uma experiência guiada, siga os tutoriais passo a passo que preparamos:

*   **[Guia Essencial: Git e GitHub para Iniciantes](./git-github/tutorial-git-github-para-iniciantes.md):** Aprenda os fundamentos do controle de versão e colaboração.
*   **[Guia Essencial: Visual Studio Code para Iniciantes](./vscode/tutorial-vscode-para-iniciantes.md):** Configure e otimize seu ambiente de desenvolvimento.
*   **[Guia de Instalação: Docker e Docker Desktop](./docker/tutorial-instalacao-docker.md):** Instale e configure o Docker no seu ambiente.
*   **[Guia de Solução: Sincronizando Volumes no Docker/Kubernetes](./volumes/tutorial-volumes-development.md):** Resolva problemas de sincronização de arquivos entre seu PC e os contêineres.
*   **[Guia de Automação: CI/CD e GitOps](./ci-cd-automation/tutorial-ci-cd-gitops.md):** Automatize o ciclo de vida do software com GitHub Actions e Argo CD.
*   **[Guia de Comandos Essenciais do `kubectl`](./kubernetes/kubectl-cheatsheet.md):** Um guia de referência rápida com os comandos mais importantes para o dia a dia com Kubernetes.
*   **[Tutorial de Traefik com Kubernetes](./traefik/tutorial-kubernetes-traefik.md):** Comece por aqui para configurar o Ingress Controller, que irá expor seus serviços.
*   **[Guia: Adicionando Novos Domínios Virtuais ao Traefik no Kubernetes](./traefik/tutorial-virtual-domains.md):** Aprenda a configurar domínios personalizados para suas aplicações.
*   **[Tutorial de Prometheus e Grafana](./monitoring/tutorial-prometheus-grafana.md):** Aprenda a observar a saúde e o desempenho das suas aplicações.

## 🚀 Como Começar

### 1. Ambiente Kubernetes (Recomendado)

Este ambiente é o foco principal do nosso guia de aprendizado.

**Passo 1: Clone o repositório**
```bash
git clone https://github.com/webertmaximiano/local.dev.git
cd local.dev
```

**Passo 2: Siga os tutoriais**

Recomendamos começar pelo **Guia de Comandos Essenciais do `kubectl`** para se familiarizar com a ferramenta e, em seguida, seguir os tutoriais de Traefik e Monitoramento.

Após configurar o Traefik, você poderá implantar as outras aplicações como o `kubernetes-dashboard`, `mysql` ou `pgsql` aplicando os manifestos com `kubectl apply -f <caminho-do-arquivo.yaml>`.

### 2. Ambiente Docker Compose/Swarm (Alternativo)

Esta é uma ótima opção para quem quer um ambiente robusto sem a complexidade inicial do Kubernetes.

**Passo 1: Clone o repositório**
```bash
git clone https://github.com/webertmaximiano/local.dev.git
cd local.dev/traefik_portainer
```

**Passo 2: Crie a rede Docker externa**
O Traefik precisa de uma rede para se comunicar com os outros contêineres que ele irá gerenciar.
```bash
docker network create traefik-proxy
```

**Passo 3: Inicie os serviços**
Este comando irá baixar as imagens e iniciar os contêineres do Traefik e do Portainer em background.
```bash
docker compose -f compose-local-dev.yml up -d
```

Após a execução, você poderá acessar:
*   **Dashboard do Traefik:** [https://traefik.local.dev](https://traefik.local.dev) (Protegido por autenticação básica. Usuário: `webert`, senha definida no `compose-local-dev.yml` ou `traefik_dynamic.toml`.)
*   **Dashboard do Portainer:** [https://portainer.local.dev](https://portainer.local.dev)

**Nota sobre o Portainer:** Se você encontrar problemas com o volume do Portainer (ex: "volume antigo"), pode ser necessário remover o volume existente para que ele seja recriado. **Isso apagará todos os dados do Portainer.** Para fazer isso, execute:
```bash
docker compose -f compose-local-dev.yml down
docker volume rm traefik_portainer_portainer_data
docker compose -f compose-local-dev.yml up -d
```

Para mais detalhes sobre como adicionar seus próprios projetos a este ambiente, consulte o `README.md` dentro da pasta `/traefik_portainer`.

## 🌟 Próximos Passos

Este repositório é um projeto vivo e continuará a ser atualizado com:
*   Novos tutoriais, cobrindo as fases de CI/CD com ArgoCD e GitHub Actions.
*   Mais exemplos de aplicações para você implantar.
*   Melhorias na documentação e nos scripts de automação.

Sinta-se à vontade para contribuir, abrir issues e fazer parte da comunidade **Agilizando o Futuro**!