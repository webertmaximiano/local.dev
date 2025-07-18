# Guia de Instalação: Docker e Docker Desktop no Ubuntu 24.04 LTS

Este guia irá te ajudar a instalar o Docker Engine e o Docker Desktop no seu sistema Ubuntu 24.04 LTS. O Docker é uma ferramenta essencial para criar, implantar e executar aplicações em contêineres, garantindo que seu ambiente de desenvolvimento seja consistente e portátil.

## 🚀 O que é Docker?

**Docker** é uma plataforma que permite empacotar aplicações e todas as suas dependências em "contêineres". Esses contêineres são unidades leves e portáteis que podem ser executadas de forma consistente em qualquer ambiente, seja seu computador local, um servidor ou a nuvem. Isso resolve o famoso problema "na minha máquina funciona!".

## 💻 O que é Docker Desktop?

**Docker Desktop** é uma aplicação fácil de usar para Windows, macOS e Linux que inclui o Docker Engine, Docker CLI, Docker Compose, Kubernetes e Credential Helper. Ele fornece uma interface gráfica para gerenciar seus contêineres e simplifica muito o processo de desenvolvimento com Docker.

## 🛠️ Pré-requisitos

*   Um sistema operacional Ubuntu 24.04 LTS.
*   Acesso a um terminal com privilégios de `sudo`.
*   Conexão com a internet.

**Para outros sistemas operacionais:**
*   **Windows:** Siga a documentação oficial: [Install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/)
*   **macOS:** Siga a documentação oficial: [Install Docker Desktop on Mac](https://docs.docker.com/desktop/install/mac-install/)

## 1. Instalação do Docker Engine

É altamente recomendado instalar o Docker Engine a partir dos repositórios oficiais do Docker para garantir que você obtenha a versão mais recente e segura.

### 1.1. Desinstalar versões antigas (se houver)

Remova quaisquer pacotes Docker conflitantes que possam estar presentes no seu sistema:

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

### 1.2. Atualizar o índice de pacotes `apt` e instalar pacotes necessários

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
```

### 1.3. Adicionar a chave GPG oficial do Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### 1.4. Adicionar o repositório Docker às fontes do Apt

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 1.5. Atualizar o índice de pacotes `apt` novamente

```bash
sudo apt-get update
```

### 1.6. Instalar Docker Engine, containerd e Docker Compose

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 1.7. Adicionar seu usuário ao grupo `docker` (para executar comandos Docker sem `sudo`)

```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Importante:** Você pode precisar fazer logout e login novamente para que as alterações tenham efeito total.

### 1.8. Verificar a instalação do Docker Engine

```bash
docker run hello-world
```

Este comando baixa uma imagem de teste e a executa em um contêiner. Se tudo estiver correto, você verá uma mensagem de "Hello from Docker!".

## 2. Instalação do Docker Desktop

O Docker Desktop para Linux requer que o Docker Engine já esteja instalado.

### 2.1. Requisitos do Sistema

Certifique-se de que seu sistema atende aos requisitos:
*   Kernel de 64 bits
*   Suporte de CPU para virtualização
*   Pelo menos 4 GB de RAM
*   Suporte a virtualização KVM (verifique se está habilitado na BIOS/UEFI)

Se você não estiver usando um ambiente de desktop GNOME, pode ser necessário instalar o `gnome-terminal`:

```bash
sudo apt install gnome-terminal
```

### 2.2. Baixar o pacote `.deb` do Docker Desktop

Vá para a página oficial de download do Docker Desktop para Linux: [Download Docker Desktop for Linux](https://docs.docker.com/desktop/install/ubuntu/) e baixe o pacote `.deb` estável mais recente para Ubuntu.

### 2.3. Instalar o pacote do Docker Desktop

Navegue até o diretório `Downloads` (ou onde você salvou o arquivo `.deb`) e instale-o usando `apt`. Substitua `docker-desktop-<version>-<arch>.deb` pelo nome real do arquivo que você baixou.

```bash
sudo apt install ./docker-desktop-<version>-<arch>.deb
```

Por exemplo:

```bash
sudo apt install ./docker-desktop-4.29.0-amd64.deb
```

Você pode ver um aviso sobre a instalação de um pacote baixado; isso geralmente pode ser ignorado.

### 2.4. Iniciar o Docker Desktop

Você pode iniciar o Docker Desktop a partir do menu de aplicativos do seu sistema. Na primeira vez que você o executar, será necessário aceitar o Contrato de Serviço de Assinatura do Docker. Você também pode configurar o Docker Desktop para iniciar automaticamente ao fazer login nas suas configurações.

## Conclusão

Com o Docker Engine e o Docker Desktop instalados, você está pronto para começar a trabalhar com contêineres e explorar o mundo do desenvolvimento moderno!
