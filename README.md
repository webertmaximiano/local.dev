# Ambiente de Desenvolvimento Local com Docker, Traefik e Portainer

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-2496ED?style=for-the-badge&logo=traefikmesh&logoColor=white&color=9D61E1)
![Portainer](https://img.shields.io/badge/Portainer-13253A?style=for-the-badge&logo=portainer&logoColor=white&color=13BEF9)

## 🎯 Sobre o Projeto

Este projeto configura um ambiente de desenvolvimento local robusto e flexível utilizando Docker. Ele usa o **Traefik** como um reverse proxy para gerenciar e rotear o tráfego para múltiplos contêineres e o **Portainer** para fornecer uma interface gráfica de gerenciamento dos ambientes Docker.

O objetivo é simplificar o processo de desenvolvimento, permitindo que múltiplos projetos rodem simultaneamente com domínios locais (ex: `meuprojeto.localhost`) e com certificados SSL locais válidos, tudo de forma automatizada.

## ✨ Principais Funcionalidades

* **Reverse Proxy Automatizado:** Traefik descobre e configura rotas para novos serviços automaticamente.
* **Gerenciamento Visual:** Portainer permite gerenciar contêineres, volumes e redes através de uma UI intuitiva.
* **SSL Local:** Configuração para gerar certificados SSL automaticamente para seus domínios locais, permitindo o desenvolvimento com HTTPS.
* **Isolamento:** Cada projeto roda em seu próprio contêiner, garantindo um ambiente limpo e sem conflitos.

## 🛠️ Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas:
* [Docker](https://www.docker.com/get-started)
* [Docker Compose](https://docs.docker.com/compose/install/)

## 🚀 Instalação e Configuração

Siga os passos abaixo para colocar o ambiente no ar:

1.  **Clone este repositório:**
    ```bash
    git clone [https://github.com/webertmaximiano/local.dev.git](https://github.com/webertmaximiano/local.dev.git)
    cd local.dev
    ```

2.  **Crie a rede Docker externa:**
    O Traefik precisa de uma rede para se comunicar com os outros contêineres que ele irá gerenciar.
    ```bash
    docker network create traefik-proxy
    ```

3.  **Inicie os serviços:**
    Este comando irá baixar as imagens e iniciar os contêineres do Traefik e do Portainer em background.
    ```bash
    docker-compose up -d
    ```

Após a execução, você poderá acessar:
* **Dashboard do Traefik:** [http://traefik.localhost](http://traefik.localhost)
* **Dashboard do Portainer:** [http://portainer.localhost](http://portainer.localhost)

Na primeira vez que acessar o Portainer, ele pedirá para você criar um usuário administrador.

## 💡 Como Adicionar um Novo Projeto

Para adicionar um projeto seu (ex: um site em Laravel) a este ambiente, você precisa configurar o `docker-compose.yml` desse projeto para usar a rede do Traefik e adicionar as `labels` corretas.

Veja um exemplo de um `docker-compose.yml` para um projeto Laravel:

```yaml
version: '3.8'

services:
  # Serviço da Aplicação Laravel
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: meu-projeto-app
    restart: unless-stopped
    working_dir: /var/www/
    volumes:
      - ./:/var/www
    networks:
      - traefik-proxy # Conecta na rede do Traefik

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.meu-projeto.rule=Host(`meu-projeto.localhost`)"
      - "traefik.http.routers.meu-projeto.entrypoints=web"
      - "traefik.http.services.meu-projeto.loadbalancer.server.port=80" # Porta interna da aplicação
      - "traefik.docker.network=traefik-proxy"

  # Outros serviços como banco de dados...
  db:
    # ...

networks:
  traefik-proxy:
    external: true # Declara que a rede é externa e já foi criada
