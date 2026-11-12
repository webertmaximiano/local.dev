# Guia de Aprendizado: Do Zero à Nuvem com Kubernetes - Projeto Agilizando o Futuro!

Olá, futuro desenvolvedor(a)!

Bem-vindo(a) ao **Agilizando o Futuro!** Meu nome é Webert Maximiano, e vou te guiar nesta jornada para construir um ambiente de desenvolvimento moderno, poderoso e alinhado com o que o mercado de tecnologia procura.

O objetivo deste guia é claro: te levar do zero ao ponto em que você consiga desenvolver, testar e implantar aplicações escaláveis usando as mesmas ferramentas que as grandes empresas de tecnologia usam. E o melhor: faremos tudo isso com software livre, open source e serviços gratuitos, rodando no seu próprio computador com Ubuntu.

Vamos começar!

### Nossa Filosofia: "Comece Local, Pense em Nuvem"

Tudo o que vamos construir no seu computador será um espelho de como as aplicações funcionam na nuvem (como na Amazon AWS, Google Cloud ou Microsoft Azure). A ideia é que, ao final, você tenha a confiança de que sua aplicação pode ser implantada em qualquer lugar com o mínimo de esforço.

---

## Sua Jornada de Aprendizado

Dividi nosso caminho em fases, cada uma construindo sobre a anterior. Não tenha pressa, o importante é entender bem cada conceito antes de avançar.

### Fase 0: A Fundação Essencial

Antes de falarmos em contêineres ou nuvem, você precisa dominar as ferramentas básicas que todo desenvolvedor usa diariamente.

1.  **Git & GitHub: Seu Diário de Bordo**
    *   **Por que é importante?** O Git é como um "salvar" superpoderoso para o seu código. O GitHub é a plataforma onde você guarda esse histórico online, colabora com outros e constrói seu portfólio.
    *   **Suas Ferramentas:** `git` (no terminal) e uma conta no [GitHub](https://github.com).
    *   **Sua Missão:** Aprenda os comandos essenciais: `git clone`, `git add`, `git commit`, `git push` e `git pull`. Entenda como criar *branches* para trabalhar em novas funcionalidades sem quebrar o que já funciona.

2.  **Seu Ambiente de Desenvolvimento (IDE e Linguagem)**
    *   **Por que é importante?** É aqui que a mágica acontece e você escreve seus códigos.
    *   **Sua Ferramenta:** Vamos usar o **Visual Studio Code (VS Code)**. É gratuito, poderoso e tem milhares de extensões que vão nos ajudar no futuro.
    *   **Sua Missão:** Escolha uma linguagem de programação para criar sua primeira API. Minha sugestão é começar com **Node.js** (usando o framework Express ou Fastify) ou **Python** (com FastAPI ou Flask). Crie um projeto simples, como uma lista de tarefas (To-Do List), que responda a requisições web.

### Fase 1: O Mundo dos Contêineres

Agora, vamos "empacotar" sua aplicação para que ela rode de forma idêntica em qualquer máquina.

1.  **Docker & Docker Compose: Suas Caixas Mágicas**
    *   **Por que é importante?** O Docker cria "contêineres" que isolam sua aplicação e todas as suas dependências (banco de dados, bibliotecas, etc.). Isso acaba com a clássica desculpa: "mas na minha máquina funciona!".
    *   **Suas Ferramentas:** **Docker Engine** e **Docker Compose**.
    *   **Sua Missão:**
        1.  Escreva um arquivo chamado `Dockerfile` para sua aplicação. Ele é a "receita" para construir a imagem do seu contêiner.
        2.  Use o comando `docker build` para criar essa imagem.
        3.  Use `docker run` para iniciar sua aplicação a partir da imagem.
        4.  Crie um arquivo `docker-compose.yml` para rodar múltiplos serviços juntos, como sua API e um banco de dados (Postgres ou MongoDB, por exemplo).

        > **Dica de Solução de Problemas:** Se você notar que as alterações no seu código local não estão aparecendo dentro do contêiner (problema de live reload), nós temos um guia específico para resolver isso no Ubuntu. Consulte o **[Guia de Solução: Sincronizando Volumes no Docker/Kubernetes](./volumes/tutorial-volumes-development.md)**.

    **Ambiente de Desenvolvimento Local com Docker Swarm e Traefik**

    O repositório oferece uma infraestrutura genérica para praticar operações semelhantes às de uma VPS, sem acoplar o laboratório a projetos privados.

    *   **Sua Missão:**
        1.  Leia `infra/swarm/README.md` e confira se as portas 80/443 estão livres.
        2.  Prepare HTTPS local com `make tls-setup`.
        3.  Inicie apenas o proxy central com `make traefik-up`.
        4.  Ligue Portainer quando quiser praticar a interface: `make portainer-up`. Use-o para visualizar serviços, tarefas, logs e redes; desligue-o ao terminar com `make portainer-down` para poupar recursos.
        5.  Crie uma aplicação Swarm e conecte-a à rede externa `web-local` com labels em `deploy.labels`.

    Use os manifests e comandos como configuração reproduzível; Portainer é um apoio visual para aprender e observar operações. O [guia de Portainer](./infra/swarm/portainer/README.md) apresenta exercícios e cuidados de segurança. Cada stack tem comandos próprios. O Makefile não inicia todas as opções nem para containers de outros projetos.

### Fase 2: Kubernetes como trilha avançada

Depois de aprender o fluxo de aplicação e operação em Docker Swarm, avance para Kubernetes se seus objetivos pedirem essa plataforma. Consulte [`kubernetes/README.md`](./kubernetes/README.md) para a ordem de estudo e os exemplos organizados por assunto.

1.  **Cluster local, kubectl e workloads**
    *   **Por que é importante?** Kubernetes oferece outro modelo de orquestração, com objetos e práticas próprias. Um cluster local permite aprender esses conceitos sem alterar o laboratório Swarm.
    *   **Suas Ferramentas:** Um cluster Kubernetes local, como Docker Desktop ou K3s, e a ferramenta de linha de comando **`kubectl`**.
    *   **Sua Missão:**
        1.  Prepare o cluster e confira o contexto ativo com `kubectl config get-contexts`.
        2.  Siga [`kubernetes/cluster/kubectl-cheatsheet.md`](./kubernetes/cluster/kubectl-cheatsheet.md).
        3.  Aprenda os **conceitos fundamentais do Kubernetes**:
            *   `Pod`: A menor unidade executável; normalmente é criado e mantido por um controlador.
            *   `Deployment`: Mantém réplicas de uma aplicação stateless e oferece atualizações declarativas.
            *   `Service`: Cria um ponto de acesso interno e estável para seus Pods.
            *   `Ingress`: Expõe seu serviço para o mundo exterior, permitindo que você acesse sua API pelo navegador. Ingress precisa de um Ingress Controller instalado no cluster, como o Traefik; o recurso Ingress sozinho não instala esse controlador.
        4.  **Trabalho Prático:** Crie os recursos Kubernetes equivalentes à aplicação, começando por Deployment e Service. Os manifests do Swarm não são aplicados diretamente no Kubernetes. Como passos adicionais, siga os tutoriais de [MySQL](./kubernetes/workloads/databases/mysql/tutorial-subindo-o-mysql.md) ou [Redis](./kubernetes/workloads/databases/redis/tutorial-subindo-o-redis.md).

### Fase 3: Automação com CI/CD (GitOps)

Vamos automatizar as verificações e a criação da imagem; a implantação GitOps acontece depois de atualizar e revisar a versão desejada no repositório de configuração.

1.  **CI (Continuous Integration) com GitHub Actions**
    *   **Por que é importante?** Para automatizar os testes e a criação das suas imagens Docker sempre que você enviar código novo para o GitHub.
    *   **Sua Ferramenta:** **GitHub Actions**. Cotas, limites e cobrança variam conforme o plano e o tipo de repositório; consulte as condições atuais da sua conta.
    *   **Sua Missão:** Siga o [tutorial de CI/CD e GitOps](./ci-cd-automation/tutorial-ci-cd-gitops.md). Comece executando lint e build nos pull requests; depois publique uma imagem identificada pelo commit no GHCR após a integração em `main`. Confira a visibilidade do pacote e os limites atuais do GitHub.

2.  **CD (Continuous Deployment) com Argo CD**
    *   **Por que é importante?** Para que o estado do cluster seja aplicado a partir de manifests versionados no Git. Argo CD não implanta uma imagem apenas porque ela foi publicada; o manifesto GitOps precisa ser atualizado.
    *   **Sua Ferramenta:** **Argo CD**, uma ferramenta open source de GitOps para Kubernetes.
    *   **Sua Missão:**
        1.  Pratique com um cluster Kubernetes local ou remoto; uma VPS não é obrigatória para aprender.
        2.  Configure Argo CD para acompanhar um repositório GitOps com manifests sem segredos.
        3.  Depois da CI publicar a imagem, atualize a tag no manifesto por um pull request. Após integrar a mudança, Argo CD sincroniza o cluster conforme a política configurada. Veja o [tutorial passo a passo](./ci-cd-automation/tutorial-ci-cd-gitops.md).

### Fase 4: Monitoramento e Observabilidade

Com a aplicação no ar, como saber se ela está funcionando bem?

1.  **Monitoramento Kubernetes com Prometheus & Grafana**
    *   **Por que é importante?** Prometheus coleta métricas e Grafana permite consultá-las e visualizá-las. Logs são uma trilha separada e exigem uma solução própria de coleta e consulta.
    *   **Suas Ferramentas:** **Prometheus** (para coletar métricas) e **Grafana** (para criar painéis e visualizar os dados).
    *   **Sua Missão:**
        1.  Siga o [tutorial Kubernetes de Prometheus e Grafana](./kubernetes/observability/prometheus-grafana/tutorial-prometheus-grafana.md), usando Helm.
        2.  Confira o [guia de monitoramento de aplicações](./kubernetes/observability/prometheus-grafana/tutorial-monitoring-applications.md) e adapte a coleta às métricas da aplicação.
        3.  Crie um dashboard e pratique consultas e alertas; desligue os componentes quando não estiver estudando para liberar recursos do computador.

---

### Resumo da Sua Jornada

| Fase | Conceito | Ferramentas | Objetivo de Aprendizado |
| :--- | :--- | :--- | :--- |
| **0** | Fundação | `git`, GitHub, VS Code, Node.js/Python | Controlar versão e criar uma API simples. |
| **1** | Contêineres | Docker Engine, Docker Compose | Empacotar a aplicação e seus serviços. |
| **2** | Orquestração | Docker Swarm; Kubernetes como trilha avançada | Operar a aplicação em contêineres e estudar outros orquestradores quando necessário. |
| **3** | CI/CD (GitOps) | GitHub Actions, **Argo CD**, GHCR | Verificar o código, publicar uma imagem e implantar após atualizar o repositório GitOps. |
| **4** | Monitoramento | Prometheus, Grafana | Observar a saúde e o desempenho da aplicação. |

---

Esta jornada pode parecer longa, mas cada passo é uma vitória que te deixará mais perto de se tornar um(a) desenvolvedor(a) de alto nível.

Estou aqui para ajudar. Não hesite em pesquisar, perguntar e, o mais importante, experimentar. Quebre coisas, conserte-as e aprenda no processo.

**Vamos agilizar o seu futuro!**
