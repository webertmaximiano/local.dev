# Ambiente de Desenvolvimento Local com Docker, Traefik e Portainer

Este guia descreve como configurar um ambiente de desenvolvimento local utilizando Docker Compose, com Traefik atuando como reverse proxy e Portainer para o gerenciamento da interface do Docker.

Esta é a abordagem recomendada para iniciantes em contêineres antes de avançar para o Kubernetes.

## Pré-requisitos

1.  **Docker e Docker Compose:** Certifique-se de que ambos estejam instalados em sua máquina.
2.  **Entradas no arquivo `hosts`:** Para acessar os serviços através de nomes de domínio locais, adicione as seguintes linhas ao seu arquivo de hosts (`/etc/hosts` no Linux/macOS ou `C:\Windows\System32\drivers\etc\hosts` no Windows):

    ```
    127.0.0.1 traefik.local.dev
    127.0.0.1 portainer.local.dev
    ```

## Passo 1: Criar a Rede Externa do Docker

O Traefik precisa de uma rede Docker para se comunicar com os contêineres que ele irá gerenciar. Usamos uma rede externa para que ela possa ser compartilhada por múltiplos projetos do Docker Compose.

**1. Verifique se a rede já existe:**

Execute o comando abaixo para listar suas redes Docker:

```bash
docker network ls
```

Procure por uma rede chamada `web-local`.

**2. Crie a rede (se ela não existir):**

Se a rede `web-local` não aparecer na lista, crie-a com o seguinte comando:

```bash
docker network create web-local
```

## Passo 2: Subindo o Ambiente

Com a rede criada, você pode iniciar os serviços do Traefik e do Portainer.

1.  **Navegue até este diretório:**

    ```bash
    cd traefik_portainer
    ```

2.  **Execute o Docker Compose:**

    ```bash
    docker-compose -f compose-local-dev.yml up -d
    ```

    O `-d` executa os contêineres em modo "detached" (em segundo plano).

## Passo 3: Acessando os Serviços

Após os contêineres iniciarem, você poderá acessar:

*   **Dashboard do Traefik:** [https://traefik.local.dev](https://traefik.local.dev)
*   **Interface do Portainer:** [https://portainer.local.dev](https://portainer.local.dev)

Na primeira vez que acessar o Portainer, você precisará criar um usuário administrador.

## Entendendo o `compose-local-dev.yml`

*   **`services`**: Define os contêineres que compõem nossa aplicação (`traefik` e `portainer`).
*   **`image`**: Especifica a imagem Docker a ser usada, com uma **versão fixada** para garantir estabilidade.
*   **`restart: unless-stopped`**: Garante que os contêineres reiniciem automaticamente, a menos que sejam parados manualmente.
*   **`ports`**: Expõe as portas do contêiner para a máquina host. O Traefik precisa das portas `80` e `443` para capturar o tráfego web.
*   **`volumes`**: Mapeia arquivos e diretórios entre o host e o contêiner. É assim que o Traefik lê sua configuração e acessa o "socket" do Docker.
*   **`networks`**: Conecta os serviços à rede `web-local` que criamos.
*   **`labels`**: A "mágica" do Traefik. São metadados que instruem o Traefik sobre como rotear o tráfego para aquele contêiner específico (qual domínio, qual porta, se deve usar HTTPS, etc.).
*   **`networks.web-local.external: true`**: Informa ao Docker Compose para usar uma rede pré-existente chamada `web-local` em vez de criar uma nova.
*   **`volumes.portainer_data`**: Cria um volume nomeado para que os dados do Portainer (usuários, configurações) persistam mesmo que o contêiner seja removido e recriado.

## Rodando em Docker Swarm (Portainer Agent)

Para ambientes em Swarm é recomendado usar o `Portainer Agent` em todos os nós e o serviço `portainer` em modo `replicated` apenas nos managers. Existe um arquivo de exemplo para Swarm: `compose-swarm.yml`.

Principais diferenças e instruções rápidas:

- O `agent` deve rodar em todos os nós (deploy mode: `global`) e expõe a comunicação que o `portainer` usa para gerenciar os agentes.
- O `portainer` deve ser colocado em `replicated` com `placement: constraints: [node.role == manager]`.
- O Portainer comunica-se com os agentes via `tcp://tasks.agent:9001` (configurado no `command`).
- Para expor o Portainer via Traefik em Swarm, adicionamos labels no serviço `portainer` (ex: `traefik.http.routers.portainer.rule=Host(...)`, `traefik.http.services.portainer.loadbalancer.server.port=9000`).

Exemplo: para usar em Swarm, crie as redes externas `portainer_agent_network` e `traefik-public`, e um volume externo `portainer_data`, e então aplique os stacks separados para Traefik e Portainer:

```bash
docker network create --driver overlay portainer_agent_network
docker network create --driver overlay web-local
docker volume create portainer_data

# Deploy Traefik (stack separado)
docker stack deploy -c compose-traefik-swarm.yml traefik

# Deploy Portainer + Agent
docker stack deploy -c compose-portainer-swarm.yml portainer
```

Observação: ajuste o `Host(...)` das labels no `compose-portainer-swarm.yml` para o domínio desejado (ex: `portainer.corridajusta.com.br`).

Este diretório agora possui dois arquivos de stack para Swarm:

- `compose-traefik-swarm.yml` — stack dedicado do Traefik (recomendo manter separado)
- `compose-portainer-swarm.yml` — stack do Portainer + Agent

## Certificados TLS (problemas comuns e correção aplicada)

- Sintoma observado: após remover e recriar stacks, o navegador mostrou erro "Sua conexão não é particular" (net::ERR_CERT_AUTHORITY_INVALID) ao acessar `traefik.local.dev` ou `portainer.local.dev`.
- Causa frequente: o Traefik não estava encontrando o arquivo de certificado montado (path incorreto no arquivo dinâmico `tls.yml`) e passou a servir uma cadeia inválida/default.

Correção aplicada neste repositório:

- Conferir onde o diretório de certificados é montado no `compose`/`stack`. No `compose-traefik-swarm.yml` usamos:

```yaml
        - "./certs/local.dev:/certs:ro"
```

Isso significa que dentro do container os arquivos estarão em `/certs/<nome-do-arquivo>` (ex: `/certs/local.dev.fullchain.crt`).

- Ajuste necessário no arquivo dinâmico que o Traefik carrega (`traefik_portainer/config/traefik/tls.yml`): usar o caminho exato dos arquivos que existem dentro do container. Exemplo adotado aqui:

```yaml
tls:
    certificates:
        - certFile: "/certs/local.dev.fullchain.crt"
            keyFile:  "/certs/local.dev.key"
```

- Comandos úteis (executados/validados aqui):

```bash
# criar rede overlay (Swarm)
docker network create --driver overlay --attachable web-local

# remover rede local antiga (se existir) e recriar em modo swarm
docker network rm web-local || true
docker network create --driver overlay --attachable web-local

# redeploy do Traefik e forçar reload
docker stack deploy -c compose-traefik-swarm.yml traefik
docker service update --force traefik_traefik
```

- Validando TLS a partir do host (exemplo):

```bash
curl -vk --cacert traefik_portainer/certs/local.dev/rootCA.pem https://traefik.local.dev/
curl -vk --resolve portainer.local.dev:443:127.0.0.1 --cacert traefik_portainer/certs/local.dev/rootCA.pem https://portainer.local.dev/
```

- Instalar a CA no sistema (Linux Debian/Ubuntu) para confiar no certificado local gerado pelo `mkcert`:

```bash
sudo cp traefik_portainer/certs/local.dev/rootCA.pem /usr/local/share/ca-certificates/local-dev-rootCA.crt
sudo update-ca-certificates
```

- Dica: limpe HSTS no navegador (Chrome) em `chrome://net-internals/#hsts` caso o domínio tenha sido marcado com HSTS após testes falhos.

Se preferir, siga o tutorial `traefik/tutorial-mkcert-localdev.md` para gerar os certificados com `mkcert` e preparar o `fullchain` usado pelo Traefik.

