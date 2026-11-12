SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help
.NOTPARALLEL:

TRAEFIK_DIR := infra/swarm/traefik
PORTAINER_DIR := infra/swarm/portainer
TRAEFIK_SECRET_PREFIX := traefik_dashboard_users_v

.PHONY: help swarm-init networks portainer-network portainer-volume tls-setup check-tls traefik-secret traefik-secret-rotate ensure-traefik traefik-up traefik-down portainer-up portainer-down status logs-traefik

help:
	@echo "Targets do ambiente local (não iniciam projetos de aplicação):"
	@echo "  make tls-setup      Instala a CA local e gera o certificado wildcard"
	@echo "  make traefik-secret-rotate Troca a senha BasicAuth do dashboard Traefik"
	@echo "  make traefik-up     Sobe/reaplica somente a stack central do Traefik"
	@echo "  make portainer-up   Verifica o Traefik e sobe Portainer + Agent (opcional)"
	@echo "  make portainer-down Para somente Portainer + Agent"
	@echo "  make traefik-down   Para somente o Traefik central"
	@echo "  make status         Lista stacks e serviços Swarm"
	@echo "  make logs-traefik   Acompanha os logs do Traefik"

swarm-init:
	@state="$$(docker info --format '{{.Swarm.LocalNodeState}}')"; \
	if [[ "$$state" == "inactive" ]]; then \
		docker swarm init; \
	elif [[ "$$state" == "active" ]]; then \
		echo "Swarm já está ativo neste Docker Engine."; \
	else \
		echo "Estado Swarm inesperado: $$state" >&2; exit 1; \
	fi

networks: swarm-init
	@for network in web-local monitoring; do \
		if docker network ls --format '{{.Name}}' | grep -Fxq "$$network"; then \
			driver="$$(docker network inspect --format '{{.Driver}}' "$$network")"; \
			if [[ "$$driver" != "overlay" ]]; then \
				echo "A rede $$network precisa ser overlay." >&2; exit 1; \
			fi; \
			if [[ "$$network" == "web-local" ]]; then \
				attachable="$$(docker network inspect --format '{{.Attachable}}' "$$network")"; \
				[[ "$$attachable" == "true" ]] || { echo "A rede web-local precisa ser attachable." >&2; exit 1; }; \
			fi; \
		else \
			if [[ "$$network" == "web-local" ]]; then \
				docker network create --driver overlay --attachable "$$network"; \
			else \
				docker network create --driver overlay "$$network"; \
			fi; \
		fi; \
	done

portainer-volume:
	@if ! docker volume ls --format '{{.Name}}' | grep -Fxq portainer_data; then docker volume create portainer_data; else echo "Volume portainer_data já existe."; fi

portainer-network: networks
	@if ! docker network ls --format '{{.Name}}' | grep -Fxq portainer_agent_network; then \
		docker network create --driver overlay portainer_agent_network; \
	else \
		driver="$$(docker network inspect --format '{{.Driver}}' portainer_agent_network)"; \
		[[ "$$driver" == "overlay" ]] || { echo "portainer_agent_network precisa ser overlay." >&2; exit 1; }; \
	fi

tls-setup:
	@command -v mkcert >/dev/null || { echo "Instale mkcert; veja infra/swarm/traefik/README.md" >&2; exit 1; }
	@mkcert -install
	@mkdir -p $(TRAEFIK_DIR)/certs/local.dev
	@if [[ ! -s $(TRAEFIK_DIR)/certs/local.dev/local.dev.fullchain.crt || ! -s $(TRAEFIK_DIR)/certs/local.dev/local.dev.key ]]; then \
		mkcert -cert-file $(TRAEFIK_DIR)/certs/local.dev/local.dev.fullchain.crt \
		  -key-file $(TRAEFIK_DIR)/certs/local.dev/local.dev.key \
		  "*.local.dev" local.dev; \
	fi

check-tls:
	@test -s $(TRAEFIK_DIR)/certs/local.dev/local.dev.fullchain.crt -a -s $(TRAEFIK_DIR)/certs/local.dev/local.dev.key || { echo "Execute make tls-setup antes de subir o Traefik." >&2; exit 1; }

traefik-secret: swarm-init
	@if ! docker secret ls --format '{{.Name}}' | grep -E '^$(TRAEFIK_SECRET_PREFIX)[0-9]+$$' | grep -q .; then \
		command -v htpasswd >/dev/null || { echo "Instale apache2-utils para obter htpasswd." >&2; exit 1; }; \
		htpasswd -nB admin | docker secret create $(TRAEFIK_SECRET_PREFIX)1 -; \
	else \
		echo "Docker Secret BasicAuth já existe; para trocar a senha use make traefik-secret-rotate."; \
	fi

# Solicita a senha sem eco, cria nova versão e reaplica somente a stack do Traefik.
traefik-secret-rotate: networks check-tls
	@command -v htpasswd >/dev/null || { echo "Instale apache2-utils para obter htpasswd." >&2; exit 1; }
	@current="$$(docker secret ls --format '{{.Name}}' | grep -E '^$(TRAEFIK_SECRET_PREFIX)[0-9]+$$' | sed 's/^$(TRAEFIK_SECRET_PREFIX)//' | sort -n | tail -1)"; \
	next=$$(( $${current:-0} + 1 )); \
	secret="$(TRAEFIK_SECRET_PREFIX)$$next"; \
	echo "Criando nova credencial BasicAuth para admin."; \
	htpasswd -nB admin | docker secret create "$$secret" -; \
	cd $(TRAEFIK_DIR) && TRAEFIK_SECRET="$$secret" docker stack deploy -c stack.yml traefik

traefik-up: networks check-tls traefik-secret
	@secret="$$(docker secret ls --format '{{.Name}}' | grep -E '^$(TRAEFIK_SECRET_PREFIX)[0-9]+$$' | sort -V | tail -1)"; \
	cd $(TRAEFIK_DIR) && TRAEFIK_SECRET="$$secret" docker stack deploy -c stack.yml traefik

# Para dependências opcionais: preserva o Traefik se o serviço já está saudável.
ensure-traefik: networks check-tls traefik-secret
	@replicas="$$(docker service ls --filter name=traefik_traefik --format '{{.Replicas}}')"; \
	if [[ "$$replicas" == "1/1" ]]; then \
		echo "Traefik já está saudável (1/1); mantendo a stack atual."; \
	else \
		echo "Traefik ausente ou não saudável; iniciando/reaplicando a stack."; \
		secret="$$(docker secret ls --format '{{.Name}}' | grep -E '^$(TRAEFIK_SECRET_PREFIX)[0-9]+$$' | sort -V | tail -1)"; \
		cd $(TRAEFIK_DIR) && TRAEFIK_SECRET="$$secret" docker stack deploy -c stack.yml traefik; \
	fi

traefik-down:
	@docker stack rm traefik

portainer-up: ensure-traefik portainer-network portainer-volume
	@cd $(PORTAINER_DIR) && DOCKER_ROOT_DIR="$$(docker info --format '{{.DockerRootDir}}')" docker stack deploy -c stack.yml portainer

portainer-down:
	@docker stack rm portainer

status:
	@docker stack ls
	@docker service ls

logs-traefik:
	@docker service logs --follow traefik_traefik
