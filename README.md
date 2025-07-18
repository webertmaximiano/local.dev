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
* **`/mysql`**: Manifesto para implantar um servidor MySQL no Kubernetes.
* **`/pgsql`**: Manifesto para implantar um servidor PostgreSQL no Kubernetes.
* **`/traefik`**: Arquivos de configuração e tutorial para usar o Traefik como Ingress Controller no Kubernetes.

**Ambiente Docker Compose/Swarm**
* **`/traefik_portainer`**: Contém uma configuração completa com `docker-compose.yml` para rodar o Traefik como reverse proxy e o Portainer como interface de gerenciamento do Docker.

---

### 📚 Guias e Tutoriais

Para uma experiência guiada, siga os tutoriais passo a passo que preparamos:
* [Guia Essencial: Git e GitHub para Iniciantes](./git-github/README.md)
* [Guia Essencial: Visual Studio Code para Iniciantes](./vscode/README.md)
* [Guia de Instalação: Docker e Docker Desktop](./docker/README.md)
* [Guia de Automação: CI/CD e GitOps](./ci-cd-automation/README.md)
* [Guia de Comandos Essenciais do kubectl](./kubernetes/kubectl-essentials.md)
* [Tutorial de Traefik com Kubernetes](./traefik/README.md)
* [Tutorial de Prometheus e Grafana](./monitoring/README.md)

---

### 🚀 Como Começar

#### **Opção 1: Ambiente Kubernetes (Recomendado)**
Este ambiente é o foco principal do nosso guia de aprendizado.

**Passo 1: Clone o repositório**
```bash
git clone [https://github.com/webertmaximiano/local.dev.git](https://github.com/webertmaximiano/local.dev.git)
cd local.dev
