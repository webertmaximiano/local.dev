# Ambiente de Desenvolvimento Local - Projeto Agilizando o Futuro

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-2496ED?style=for-the-badge&logo=traefikmesh&logoColor=white&color=9D61E1)
![Portainer](https://img.shields.io/badge/Portainer-13253A?style=for-the-badge&logo=portainer&logoColor=white&color=13BEF9)

## 🎯 Sobre o Projeto

Bem-vindo(a) ao repositório de apoio do **[Guia de Aprendizado: Do Zero à Nuvem com Kubernetes](Guia_de_Aprendizado_Agilizando_o_Futuro.md)**!

Este projeto foi criado para fornecer um ambiente de desenvolvimento local completo e moderno, espelhando as práticas e ferramentas utilizadas em ambientes de produção na nuvem. O objetivo é permitir que você, desenvolvedor(a), possa seguir as fases do nosso guia de aprendizado de forma prática, experimentando com contêineres, orquestração e automação no seu próprio computador.

Aqui você encontrará duas abordagens principais:

1.  **Ambiente baseado em Kubernetes:** O caminho principal do nosso guia, focado em orquestração de contêineres com Kubernetes, ideal para quem quer se aprofundar em tecnologias de nuvem.
2.  **Ambiente baseado em Docker Compose/Swarm:** Uma alternativa mais simples para quem prefere começar com Docker puro, utilizando Traefik e Portainer para gerenciamento.

## 🛠️ Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas, de acordo com o caminho que deseja seguir:

**Para ambos os ambientes:**
*   [Git](https://git-scm.com/downloads)
*   [Docker](https://www.docker.com/get-started)

**Apenas para o ambiente Kubernetes:**
*   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
*   Um cluster Kubernetes local (ex: habilitado no Docker Desktop, ou usando [K3s](https://k3s.io/)).

## 📂 Estrutura do Repositório

Este repositório está organizado da seguinte forma:

*   `Guia_de_Aprendizado_Agilizando_o_Futuro.md`: O documento central que guia toda a sua jornada de aprendizado.
*   `README.md`: Este arquivo que você está lendo.

### Ambiente Kubernetes

*   `/kubernetes`: Contém guias e utilitários gerais sobre Kubernetes.
*   `/kubernetes-dashboard`: Arquivos para implantar o Dashboard oficial do Kubernetes.
*   `/monitoring`: Configurações e tutorial para o stack de monitoramento com Prometheus e Grafana.
*   `/mysql`: Manifesto para implantar um servidor MySQL no Kubernetes.
*   `/pgsql`: Manifesto para implantar um servidor PostgreSQL no Kubernetes.
*   `/traefik`: Arquivos de configuração e tutorial para usar o Traefik como Ingress Controller no Kubernetes.

### Ambiente Docker Compose/Swarm

*   `/traefik_portainer`: Contém uma configuração completa com `docker-compose.yml` para rodar o Traefik como reverse proxy e o Portainer como interface de gerenciamento do Docker.

## 📚 Guias e Tutoriais

Para uma experiência guiada, siga os tutoriais passo a passo que preparamos:

*   **[Guia de Comandos Essenciais do `kubectl`](./kubernetes/kubectl-cheatsheet.md):** Um guia de referência rápida com os comandos mais importantes para o dia a dia com Kubernetes.
*   **[Tutorial de Traefik com Kubernetes](./traefik/tutorial-kubernetes-traefik.md):** Comece por aqui para configurar o Ingress Controller, que irá expor seus serviços.
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

### 2. Ambiente Docker Compose/Swarm

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
docker-compose -f compose-local-dev.yml up -d
```

Após a execução, você poderá acessar:
*   **Dashboard do Traefik:** [http://traefik.localhost](http://traefik.localhost)
*   **Dashboard do Portainer:** [http://portainer.localhost](http://portainer.localhost)

Para mais detalhes sobre como adicionar seus próprios projetos a este ambiente, consulte o `README.md` dentro da pasta `/traefik_portainer`.

## 🌟 Próximos Passos

Este repositório é um projeto vivo e continuará a ser atualizado com:
*   Novos tutoriais, cobrindo as fases de CI/CD com ArgoCD e GitHub Actions.
*   Mais exemplos de aplicações para você implantar.
*   Melhorias na documentação e nos scripts de automação.

Sinta-se à vontade para contribuir, abrir issues e fazer parte da comunidade **Agilizando o Futuro**!