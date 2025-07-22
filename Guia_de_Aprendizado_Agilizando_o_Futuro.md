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

### Fase 2: Orquestração Local com Kubernetes

Sua aplicação agora roda em contêineres. O próximo passo é aprender a gerenciar e escalar esses contêineres como os profissionais.

1.  **Docker Desktop com Kubernetes Integrado: Seu Próprio Data Center no PC**
    *   **Por que é importante?** Kubernetes (ou k8s) é o sistema que orquestra contêineres em produção. O Docker Desktop já vem com um cluster Kubernetes leve e funcional, perfeito para desenvolvimento local.
    *   **Suas Ferramentas:** **Docker Desktop** (com Kubernetes habilitado) e a ferramenta de linha de comando **`kubectl`**.
    *   **Sua Missão:**
        1.  Certifique-se de que o Kubernetes está habilitado nas configurações do Docker Desktop.
        2.  Instale o `kubectl`, a ferramenta de linha de comando para interagir com o cluster. No Ubuntu, a forma mais fácil é via Snap: `sudo snap install kubectl --classic`.
        3.  Verifique se o `kubectl` está conectado ao cluster do Docker Desktop: `kubectl config get-contexts`. Você deve ver `docker-desktop` como o contexto atual.
        4.  Aprenda os **conceitos fundamentais do Kubernetes**:
            *   `Pod`: A menor unidade de computação, onde seu contêiner vive.
            *   `Deployment`: Garante que um número de cópias (réplicas) da sua aplicação esteja sempre rodando. É aqui que a escalabilidade começa!
            *   `Service`: Cria um ponto de acesso interno e estável para seus Pods.
            *   `Ingress`: Expõe seu serviço para o mundo exterior, permitindo que você acesse sua API pelo navegador. O Kubernetes do Docker Desktop já vem com um Ingress Controller, pronto para uso.
        5.  **Trabalho Prático:** Converta seu `docker-compose.yml` em arquivos de manifesto do Kubernetes (`deployment.yaml`, `service.yaml`, etc.) e implante sua aplicação no Kubernetes do Docker Desktop. Como um passo adicional, você pode seguir nosso [tutorial para implantar um banco de dados MySQL](./mysql/tutorial-subindo-o-mysql.md), um passo fundamental para a maioria das aplicações.

### Fase 3: Automação com CI/CD (GitOps)

Vamos automatizar todo o processo, desde o `git push` até a implantação da nova versão da sua aplicação.

1.  **CI (Continuous Integration) com GitHub Actions**
    *   **Por que é importante?** Para automatizar os testes e a criação das suas imagens Docker sempre que você enviar código novo para o GitHub.
    *   **Sua Ferramenta:** **GitHub Actions**. É integrado ao seu repositório e tem um plano gratuito generoso.
    *   **Sua Missão:** Crie um *workflow* (um arquivo `.yml` na pasta `.github/workflows`) que, a cada `git push`, automaticamente:
        1.  Rode os testes da sua aplicação.
        2.  Se os testes passarem, construa uma nova imagem Docker.
        3.  Envie essa imagem para o **GitHub Container Registry (ghcr.io)**, um registro de imagens gratuito.

2.  **CD (Continuous Deployment) com Argo CD**
    *   **Por que é importante?** Para que seu cluster Kubernetes se atualize sozinho sempre que uma nova imagem estiver disponível. Essa abordagem se chama **GitOps**.
    *   **Sua Ferramenta:** **Argo CD**, um projeto open source que é padrão na indústria.
    *   **Sua Missão:**
        1.  Instale o Argo CD no seu cluster K3s.
        2.  Configure-o para "observar" seu repositório no GitHub.
        3.  O fluxo será assim: você faz o `push`, o GitHub Actions cria a imagem, atualiza o arquivo de `deployment.yaml` com a nova versão da imagem, e o Argo CD detecta essa mudança e atualiza sua aplicação no K3s. **Tudo automático!**

### Fase 4: Monitoramento e Observabilidade

Com a aplicação no ar, como saber se ela está funcionando bem?

1.  **O Stack de Monitoramento: Prometheus & Grafana**
    *   **Por que é importante?** Para coletar métricas (uso de CPU, memória, etc.) e logs, permitindo que você entenda a saúde da sua aplicação e diagnostique problemas.
    *   **Suas Ferramentas:** **Prometheus** (para coletar métricas) e **Grafana** (para criar painéis e visualizar os dados).
    *   **Sua Missão:**
        1.  Instale o Prometheus e a Grafana no seu cluster. A forma mais fácil é usando o **Helm**, o gerenciador de pacotes do Kubernetes.
        2.  Configure o Prometheus para coletar as métricas da sua API.
        3.  Crie seu primeiro *dashboard* na Grafana para visualizar em tempo real o que está acontecendo com sua aplicação.

---

### Resumo da Sua Jornada

| Fase | Conceito | Ferramentas Open Source / Gratuitas | Objetivo de Aprendizado |
| :--- | :--- | :--- | :--- |
| **0** | Fundação | `git`, GitHub, VS Code, Node.js/Python | Controlar versão e criar uma API simples. |
| **1** | Contêineres | Docker Engine, Docker Compose | Empacotar a aplicação e seus serviços. |
| **2** | Orquestração | **K3s**, `kubectl` | Rodar a aplicação em um ambiente similar à nuvem, localmente. |
| **3** | CI/CD (GitOps) | GitHub Actions, **Argo CD**, `ghcr.io` | Automatizar o build, teste e deploy a partir de um `git push`. |
| **4** | Monitoramento | Prometheus, Grafana | Observar a saúde e o desempenho da aplicação. |

---

Esta jornada pode parecer longa, mas cada passo é uma vitória que te deixará mais perto de se tornar um(a) desenvolvedor(a) de alto nível.

Estou aqui para ajudar. Não hesite em pesquisar, perguntar e, o mais importante, experimentar. Quebre coisas, conserte-as e aprenda no processo.

**Vamos agilizar o seu futuro!**
