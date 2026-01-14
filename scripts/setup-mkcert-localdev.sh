#!/usr/bin/env bash
set -euo pipefail

WORKDIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$WORKDIR"

mkdir -p "$HOME/.local/bin" traefik/certs/local.dev

install_via_apt() {
	echo "Instalando via apt... (pode pedir senha sudo)"
	sudo apt-get update
	sudo apt-get install -y mkcert libnss3-tools || sudo apt-get install -y mkcert
}

install_via_pacman() {
	echo "Instalando via pacman..."
	sudo pacman -Sy --noconfirm mkcert || true
}

install_via_apk() {
	echo "Instalando via apk..."
	sudo apk add mkcert || true
}

install_via_brew() {
	echo "Instalando via brew..."
	brew install mkcert || true
}

install_via_snap() {
	echo "Instalando via snap..."
	sudo snap install mkcert --classic || true
}

download_binary() {
	echo "Baixando binário mkcert via GitHub releases"
	ARCH=$(uname -m)
	if [ "$ARCH" = "x86_64" ]; then PATTERN="linux-amd64|linux-x86_64"; else PATTERN="linux-arm64|linux-arm|aarch64"; fi
	DOWNLOAD_URL=$(curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest | grep browser_download_url | grep -E "$PATTERN" | head -n1 | sed -E 's/.*"(https:[^\"]+)".*/\1/')
	if [ -z "$DOWNLOAD_URL" ]; then
		echo "Erro: não foi possível localizar asset mkcert para arquitetura $ARCH"
		return 1
	fi
	curl -L --fail -o "$HOME/.local/bin/mkcert" "$DOWNLOAD_URL"
	chmod +x "$HOME/.local/bin/mkcert"
}

ensure_mkcert() {
	if command -v mkcert >/dev/null 2>&1; then
		echo "mkcert já instalado: $(which mkcert)"
		return 0
	fi

	if command -v apt-get >/dev/null 2>&1; then
		install_via_apt
	elif command -v pacman >/dev/null 2>&1; then
		install_via_pacman
	elif command -v apk >/dev/null 2>&1; then
		install_via_apk
	elif command -v brew >/dev/null 2>&1; then
		install_via_brew
	elif command -v snap >/dev/null 2>&1; then
		install_via_snap
	else
		download_binary
	fi

	export PATH="$HOME/.local/bin:$PATH"
	if ! command -v mkcert >/dev/null 2>&1; then
		echo "Falha: mkcert não está disponível após tentativa de instalação. Verifique manualmente."
		return 1
	fi
}

main() {
	ensure_mkcert

	echo "Instalando/registrando CA local (mkcert -install)"
	mkcert -install

	echo "Gerando certificado para *.local.dev e local.dev"
	mkcert -cert-file traefik/certs/local.dev/local.dev.crt -key-file traefik/certs/local.dev/local.dev.key '*.local.dev' local.dev

	CAROOT=$(mkcert -CAROOT)
	echo "Copiando rootCA.pem para traefik/certs/local.dev"
	cp "$CAROOT"/rootCA.pem traefik/certs/local.dev/rootCA.pem

	echo "Pronto. Arquivos gerados:"
	ls -l traefik/certs/local.dev || true

	echo "Testes sugeridos:"
	echo "  nohup openssl s_server -accept 8443 -cert traefik/certs/local.dev/local.dev.crt -key traefik/certs/local.dev/local.dev.key -WWW &"
	echo "  curl -vk --resolve portainer.local.dev:8443:127.0.0.1 https://portainer.local.dev:8443/ --cacert traefik/certs/local.dev/rootCA.pem"
}

main "$@"

