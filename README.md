# Local Development Environment with Traefik and Portainer

This repository provides a configuration to set up a local development environment using Traefik and Portainer. It aims to help developers, especially students, get familiar with containers, reverse proxy, and load balancing in Docker-based projects. This setup is designed to simplify the management of local development environments.

## Features

- **Traefik**: A modern reverse proxy and load balancer for Docker and Kubernetes environments.
- **Portainer**: A lightweight management UI that allows you to manage your Docker environments.
- **HTTPS by default**: Automatically redirects HTTP traffic to HTTPS.
- **Local development domains**: Configure multiple local domains for different services (e.g., `traefik.local.dev`, `portainer.local.dev`, `edge.local.dev`).
- **Docker socket**: Traefik interacts directly with Docker to automatically configure services based on labels.

## Prerequisites

Before using this setup, ensure you have the following installed:

- [Docker](https://www.docker.com)
- [Docker Compose](https://docs.docker.com/compose/)
- [mkcert](https://github.com/FiloSottile/mkcert) (optional, for local HTTPS certificates)

## Setup Instructions

1. **Clone the Repository**

    ```bash
    git clone https://github.com/webertmaximiano/local.dev.git
    cd local.dev
    ```

2. **Generate Local Certificates (Optional but Recommended)**

    If you have `mkcert` installed, generate local certificates for your development domains:

    ```bash
    mkcert -install
    mkcert "*.local.dev"
    ```

    Place the generated certificates in the `certs` directory within the project folder.

3. **Start the Environment**

    Use Docker Compose to start the environment:

    ```bash
    docker-compose up -d
    ```

4. **Access the Services**

    - Traefik Dashboard: [https://traefik.local.dev](https://traefik.local.dev)
    - Portainer: [https://portainer.local.dev](https://portainer.local.dev)
    - Edge Service: [https://edge.local.dev](https://edge.local.dev) (example for an additional service)

## Configuration

### Traefik

Traefik is configured to act as a reverse proxy, routing traffic based on the domain name to the appropriate services. It uses the following key settings:

- **HTTP to HTTPS redirection**: All traffic on port 80 is automatically redirected to HTTPS.
- **Local dashboard**: You can access the Traefik dashboard at `https://traefik.local.dev`.

### Portainer

Portainer is your visual Docker management interface, allowing you to easily manage containers, images, networks, and more.

- It runs on `https://portainer.local.dev` and is secured using HTTPS.

### Custom Domains

You can modify the domain names (`traefik.local.dev`, `portainer.local.dev`, etc.) in the `docker-compose.yml` to suit your needs. If you're using `mkcert`, don't forget to generate certificates for the new domains.

## Docker Compose Services

The `docker-compose.yml` sets up two main services:

1. **Traefik**: Handles routing and reverse proxy.

    ```yaml
    services:
      traefik:
        image: traefik:v2.4
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - ./certs:/certs
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.traefik.rule=Host(`traefik.local.dev`)"
          - "traefik.http.routers.traefik.entrypoints=websecure"
          - "traefik.http.routers.traefik.service=api@internal"
    ```

2. **Portainer**: A Docker management UI.

    ```yaml
    services:
      portainer:
        image: portainer/portainer-ce
        command: -H unix:///var/run/docker.sock
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - portainer_data:/data
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.portainer.rule=Host(`portainer.local.dev`)"
          - "traefik.http.routers.portainer.entrypoints=websecure"
    ```

    You can add more services to the `docker-compose.yml` as needed.

## Suporte e Comunidade

Este projeto foi criado com o foco principal de ajudar os alunos do projeto social [Agilizando o Futuro](https://agilizando.clubesiga.com.br/), que busca capacitar desenvolvedores ágeis para o mercado de trabalho. Se você precisar de ajuda ou tiver alguma dúvida, junte-se à nossa comunidade no [Discord](https://discord.gg/Hra9vrqgxJ), onde estaremos disponíveis para fornecer suporte.

Esperamos que este ambiente de desenvolvimento local com Traefik e Portainer facilite o aprendizado e a compreensão de conceitos como containers, proxy reverso e balanceamento de carga. Boa sorte e bons estudos!