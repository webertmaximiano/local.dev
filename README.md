<h1>Local Development Environment with Traefik and Portainer</h1>
This repository provides a configuration to set up a local development environment using Traefik and Portainer. It aims to help developers, especially students, get familiar with containers, reverse proxy, and load balancing in Docker-based projects. This setup is designed to simplify the management of local development environments.

Features
Traefik: A modern reverse proxy and load balancer for Docker and Kubernetes environments.
Portainer: A lightweight management UI that allows you to manage your Docker environments.
HTTPS by default: Automatically redirects HTTP traffic to HTTPS.
Local development domains: Configure multiple local domains for different services (e.g., traefik.local.dev, portainer.local.dev, edge.local.dev).
Docker socket: Traefik interacts directly with Docker to automatically configure services based on labels.
Prerequisites
Before using this setup, ensure you have the following installed:

Docker
Docker Compose
mkcert (optional, for local HTTPS certificates)
Setup Instructions
Clone the Repository

bash
Copiar código
git clone https://github.com/webertmaximiano/local.dev.git
cd local.dev
Generate Local Certificates (Optional but Recommended)

If you have mkcert installed, generate local certificates for your development domains:

bash
Copiar código
mkcert -install
mkcert traefik.local.dev portainer.local.dev edge.local.dev
Place the generated certificates in the certs directory within the project folder.

Start the Environment

Use Docker Compose to start the environment:

bash
Copiar código
docker-compose up -d
Access the Services

Traefik Dashboard: https://traefik.local.dev
Portainer: https://portainer.local.dev
Edge Service: https://edge.local.dev (example for an additional service)
Configuration
Traefik
Traefik is configured to act as a reverse proxy, routing traffic based on the domain name to the appropriate services. It uses the following key settings:

HTTP to HTTPS redirection: All traffic on port 80 is automatically redirected to HTTPS.
Local dashboard: You can access the Traefik dashboard at https://traefik.local.dev.
Portainer
Portainer is your visual Docker management interface, allowing you to easily manage containers, images, networks, and more.

It runs on https://portainer.local.dev and is secured using HTTPS.
Custom Domains
You can modify the domain names (traefik.local.dev, portainer.local.dev, etc.) in the docker-compose.yml to suit your needs. If you're using mkcert, don't forget to generate certificates for the new domains.

Docker Compose Services
The docker-compose.yml sets up two main services:

Traefik: Handles routing and reverse proxy.

yaml
Copiar código
services:
  traefik:
    image: traefik:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${HOME}/local.dev/:/etc/traefik
    labels:
      # Redirect HTTP to HTTPS
      - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
Portainer: A Docker management UI.

yaml
Copiar código
services:
  portainer:
    image: portainer/portainer-ce:latest
    ports:
      - "9000:9000"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(`portainer.local.dev`)"
Avoid Committing Certificates
Ensure that certificates generated locally (in the certs folder) are not committed to your repository by adding them to .gitignore:

bash
Copiar código
echo "certs/*" >> .gitignore
License
This project is licensed under the MIT License. See the LICENSE file for details.

This README provides clear instructions and context about your setup. Feel free to adjust any details to better fit your project.





