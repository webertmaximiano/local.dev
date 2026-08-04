## Tutorial: Usando `mkcert` para gerar certificados locais para `*.local.dev`

Este tutorial mostra como instalar o `mkcert`, gerar um certificado curinga para `*.local.dev`, copiar o CA público e testar HTTPS localmente (ex: `portainer.local.dev`).

Resumo dos passos:
- Instalar o binário `mkcert` (local user)
- Criar/instalar a CA local do `mkcert`
- Gerar certificado curinga para `*.local.dev` e `local.dev`
- Copiar o certificado CA público para `traefik/certs/local.dev`
- Configurar o Traefik para usar os arquivos `local.dev.crt` e `local.dev.key` (exemplo)
- Testar HTTPS servindo localmente com `openssl` e `curl`

1) Instalar `mkcert` (exemplo para Linux x86_64/arm64)

```bash
# criar pasta local para binários
mkdir -p "$HOME/.local/bin"
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ASSET=mkcert-linux-amd64
else
  ASSET=mkcert-linux-arm64
fi
DOWNLOAD_URL="https://github.com/FiloSottile/mkcert/releases/latest/download/${ASSET}"
curl -L --fail -o "$HOME/.local/bin/mkcert" "$DOWNLOAD_URL"
chmod +x "$HOME/.local/bin/mkcert"
export PATH="$HOME/.local/bin:$PATH"
mkcert -version
```

2) Instalar a CA local do `mkcert`

```bash
# instala a CA no sistema/usuarios suportados
mkcert -install

# descobrir onde o mkcert guarda a CA pública (arquivo rootCA.pem)
mkcert -CAROOT
```

3) Gerar certificado curinga para `*.local.dev` e também para `local.dev`

```bash
# cria pasta onde iremos salvar os certificados para o Traefik
mkdir -p traefik/certs/local.dev

# gerar o certificado e a chave (arquivo: local.dev.crt / local.dev.key)
mkcert -cert-file traefik/certs/local.dev/local.dev.crt -key-file traefik/certs/local.dev/local.dev.key '*.local.dev' local.dev

# copiar também o certificado CA público (sem a chave privada) para traefik
CAROOT=$(mkcert -CAROOT)
cp "$CAROOT"/rootCA.pem traefik/certs/local.dev/rootCA.pem

ls -l traefik/certs/local.dev
```

4) Configurar o Traefik para usar o certificado (exemplo - `dynamic` TLS)

Exemplo de `tls.yml` (dynamic configuration):

```yaml
tls:
  certificates:
    - certFile: "/certs/local.dev.fullchain.crt"
      keyFile: "/certs/local.dev.key"

## Problema real encontrado e solução aplicada

- Sintoma: após redeploy em Swarm, Traefik mostrou erro ao carregar o certificado e navegadores exibiram `ERR_CERT_AUTHORITY_INVALID`.
- Diagnóstico: `tls.yml` apontava para um caminho que não existia dentro do container (`/certs/local.dev/local.dev.fullchain.crt`) — neste projeto o diretório `traefik_portainer/certs/local.dev` foi montado como `/certs`, portanto os arquivos ficam em `/certs/<nome-arquivo>`.
- Solução aplicada: corrigi o caminho em `traefik_portainer/config/traefik/tls.yml` para usar `certFile: "/certs/local.dev.fullchain.crt"` e reimplantei o serviço com `docker service update --force traefik_traefik`.

Comandos úteis de verificação:

```bash
# verificar rede e criar overlay web-local
docker network ls | grep web-local || docker network create --driver overlay --attachable web-local

# redeploy do Traefik
docker stack deploy -c traefik_portainer/compose-traefik-swarm.yml traefik
docker service update --force traefik_traefik

# testar TLS a partir do host
curl -vk --cacert traefik_portainer/certs/local.dev/rootCA.pem https://traefik.local.dev/
curl -vk --resolve portainer.local.dev:443:127.0.0.1 --cacert traefik_portainer/certs/local.dev/rootCA.pem https://portainer.local.dev/
```
```

Observação: Ajuste o caminho de `certFile`/`keyFile` para onde o Traefik monta os arquivos no container/pod (ex: `/certs/...`). Se você usa o `traefik_portainer` com Docker Compose, monte `./traefik/certs:/certs`.

5) Teste rápido sem Traefik — servindo HTTPS local com `openssl` e validando `portainer.local.dev`

```bash
# inicia um servidor HTTPS simples na porta 8443 (background)
nohup openssl s_server -accept 8443 -cert traefik/certs/local.dev/local.dev.crt -key traefik/certs/local.dev/local.dev.key -WWW > /tmp/openssl-server.log 2>&1 &

# testa com curl usando --resolve para mapear o hostname local para 127.0.0.1
curl -vk --resolve portainer.local.dev:8443:127.0.0.1 https://portainer.local.dev:8443/ --cacert traefik/certs/local.dev/rootCA.pem

# veja logs do servidor se necessário
tail -n +1 /tmp/openssl-server.log
```

6) Observações de segurança e melhores práticas
- Não comite a chave privada da CA (`rootCA-key.pem`) no repositório. O `mkcert` guarda a chave da CA em `$CAROOT` — apenas copie `rootCA.pem` (o certificado público) se precisar adicioná-lo a um bundle de confiança local.
- Para ambientes de equipe, prefira gerar e distribuir apenas o `rootCA.pem` (público) e deixar cada desenvolvedor gerar suas próprias chaves/CSRs localmente.

7) Healthchecks no Docker Swarm (por que adicioná-los)

Adicionar `healthcheck` nos serviços Traefik e Portainer no ambiente Swarm ajuda o orquestrador a detectar containers que estão vivos mas sem responder corretamente (por exemplo: processo travado, endpoint interno com erro, ou falha parcial). Quando o Swarm recebe repetidos sinais de "unhealthy", ele pode reiniciar a tarefa, ajudando a manter a disponibilidade do serviço sem intervenção manual.

- Benefícios:
  - Reinício automático de tarefas com problemas.
  - Integração com alerting/monitoramento que observa estados de saúde.
  - Comportamento previsível durante deploys/rolling updates.

- Implementação (exemplo): nos arquivos de compose usados neste repositório (`traefik_portainer/compose-traefik-swarm.yml` e `traefik_portainer/compose-portainer-swarm.yml`) adicionamos checks simples que sondam os endpoints internos:

  - Traefik: `http://127.0.0.1:8080/ping`
  - Portainer Agent: `http://127.0.0.1:9001/_ping`
  - Portainer (UI/API): `http://127.0.0.1:9000/api/status`

- Atenção com imagens base (limitação comum):
  - Os comandos de `healthcheck` que usamos usam `curl` (`curl -fsS <url> || exit 1`). Se a imagem do serviço não incluir `curl` (algumas imagens minimalistas não incluem), o próprio healthcheck irá falhar e o container será marcado como `unhealthy` mesmo que o serviço esteja funcionando.
  - Alternativas:
    - Usar uma imagem base que inclua `curl` ou `wget` (ex.: variantes baseadas em `alpine`/`debian`).
    - Adicionar um pequeno sidecar/serviço de verificação que rode as sondas e exponha um endpoint de liveliness para o serviço principal.
    - Implementar um health endpoint no próprio serviço (quando aplicável) e usar uma imagem de check externa para sondá-lo.

   - Observação sobre `HEALTHCHECK` embutido nas imagens:
     - Algumas imagens (ou versões "distroless") podem declarar um `HEALTHCHECK` que é executado com `CMD-SHELL` e espera um shell (`/bin/sh`). Se a imagem não incluir `/bin/sh`, esse check falhará e o Swarm marcará o container como `unhealthy` mesmo quando o serviço estiver operando.
     - Solução rápida para contornar isso no `docker-compose`/`stack` do Swarm: desabilitar o healthcheck herdado pela imagem adicionando no serviço:

  ```yaml
  services:
    portainer:
      image: portainer/portainer-ce:2.33.1
      # ...
      healthcheck:
        disable: true
  ```

     - Melhor alternativa: fornecer um healthcheck compatível (usar `CMD` com binário presente, ou usar um sidecar de verificação que execute sondas externas). Reintroduza healthchecks apenas após validar que o comando usado está disponível na imagem ou que a estratégia de sidecar está funcionando.

Em resumo: healthchecks aumentam a resiliência do Swarm, mas certifique-se de que os binários usados nas sondas existam dentro da imagem do container ou use uma estratégia alternativa.

7) Integração com `traefik_portainer` (Docker Swarm)

No `compose-traefik-swarm.yml` monte o diretório `certs/local.dev` como volume para o Traefik, por exemplo:

```yaml
services:
  traefik:
    volumes:
      - ./certs/local.dev:/certs:ro
```

Em seguida, o `config/traefik/tls.yml` deve apontar para `/certs/local.dev.fullchain.crt` e `/certs/local.dev.key`.

---

Se quiser, eu posso gerar os certificados aqui neste ambiente e validar o acesso `https://portainer.local.dev:8443` com os comandos acima — quer que eu proceda com a instalação e geração dos certificados agora?

**Como executar o script de instalação (recomendo usar este script)**

1) Torne o script executável (opcional):

```bash
chmod +x scripts/setup-mkcert-localdev.sh
```

2) Execute o script (pode pedir `sudo` ao instalar pacotes):

```bash
# executar com bash
bash scripts/setup-mkcert-localdev.sh

# ou, se tornou executável
./scripts/setup-mkcert-localdev.sh
```

3) O que o script faz
- Detecta gerenciador de pacotes (`apt`, `pacman`, `apk`, `brew`, `snap`) e tenta instalar `mkcert` por lá.
- Se não houver pacote disponível, baixa o binário do release mais recente do GitHub para `$HOME/.local/bin`.
- Executa `mkcert -install`, gera `local.dev.crt` e `local.dev.key` e copia `rootCA.pem` para `traefik/certs/local.dev`.

4) Verificar arquivos gerados:

```bash
ls -l traefik/certs/local.dev
```markdown
## Tutorial: Usando `mkcert` para gerar certificados locais para `*.local.dev`

Este tutorial mostra como instalar o `mkcert`, gerar um certificado curinga para `*.local.dev`, copiar o CA público e testar HTTPS localmente (ex: `portainer.local.dev`).

Resumo dos passos:
- Instalar o binário `mkcert` (local user)
- Criar/instalar a CA local do `mkcert`
- Gerar certificado curinga para `*.local.dev` e `local.dev`
- Colocar os arquivos em `traefik_portainer/certs/local.dev`
- Configurar o Traefik para entregar a cadeia completa (fullchain)
- Testar HTTPS servindo localmente com `openssl` e `curl`

1) Instalar `mkcert` (exemplo para Linux x86_64/arm64)

```bash
# criar pasta local para binários
mkdir -p "$HOME/.local/bin"
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ASSET=mkcert-linux-amd64
else
  ASSET=mkcert-linux-arm64
fi
DOWNLOAD_URL="https://github.com/FiloSottile/mkcert/releases/latest/download/${ASSET}"
curl -L --fail -o "$HOME/.local/bin/mkcert" "$DOWNLOAD_URL"
chmod +x "$HOME/.local/bin/mkcert"
export PATH="$HOME/.local/bin:$PATH"
mkcert -version
```

2) Instalar a CA local do `mkcert`

```bash
# instala a CA no sistema/usuarios suportados
mkcert -install

# descobrir onde o mkcert guarda a CA pública (arquivo rootCA.pem)
mkcert -CAROOT
```

3) Gerar certificado curinga para `*.local.dev` e também para `local.dev`

```bash
# Para o layout usado neste repositório (Docker Swarm / traefik_portainer)
# salve os certificados em `traefik_portainer/certs/local.dev`.
mkdir -p traefik_portainer/certs/local.dev

# gerar o certificado e a chave
mkcert -cert-file traefik_portainer/certs/local.dev/local.dev.crt \
  -key-file traefik_portainer/certs/local.dev/local.dev.key '*.local.dev' local.dev

# copiar também o certificado CA público (sem a chave privada)
CAROOT=$(mkcert -CAROOT)
cp "$CAROOT"/rootCA.pem traefik_portainer/certs/local.dev/rootCA.pem

# Opcional: criar um fullchain (certificado + root) para que o Traefik entregue a cadeia completa
cat traefik_portainer/certs/local.dev/local.dev.crt \
  traefik_portainer/certs/local.dev/rootCA.pem \
  > traefik_portainer/certs/local.dev/local.dev.fullchain.crt

ls -l traefik_portainer/certs/local.dev
```

4) Configurar o Traefik para usar o certificado (exemplo - `dynamic` TLS)

Exemplo de `tls.yml` (dynamic configuration) — aponte para o `fullchain` criado:

```yaml
tls:
  certificates:
    - certFile: "/certs/local.dev.fullchain.crt"
      keyFile: "/certs/local.dev.key"
```

Observações importantes:
- No `traefik_portainer/compose-traefik-swarm.yml` montamos `./certs/local.dev` em `/certs` no container.
- No `traefik_portainer/config/traefik/traefik.yml` o provider file deve apontar para `/etc/traefik/conf/tls.yml` (ex.: `providers.file.filename: /etc/traefik/conf/tls.yml`).
- Após copiar/gerar os arquivos, force um reload do Traefik no Swarm: `docker service update --force traefik_traefik`.

5) Teste rápido sem Traefik — servindo HTTPS local com `openssl` e validando `portainer.local.dev`

```bash
# inicia um servidor HTTPS simples na porta 8443 (background)
nohup openssl s_server -accept 8443 -cert traefik_portainer/certs/local.dev/local.dev.fullchain.crt -key traefik_portainer/certs/local.dev/local.dev.key -WWW > /tmp/openssl-server.log 2>&1 &

# testa com curl usando --resolve para mapear o hostname local para 127.0.0.1
curl -vk --resolve portainer.local.dev:8443:127.0.0.1 https://portainer.local.dev:8443/ --cacert traefik_portainer/certs/local.dev/rootCA.pem

# veja logs do servidor se necessário
tail -n +1 /tmp/openssl-server.log
```

6) Observações de segurança e melhores práticas
- Não comite a chave privada da CA (`rootCA-key.pem`) no repositório. O `mkcert` guarda a chave da CA em `$CAROOT` — apenas copie `rootCA.pem` (o certificado público) se precisar adicioná-lo a um bundle de confiança local.
- Para ambientes de equipe, prefira gerar e distribuir apenas o `rootCA.pem` (público) e deixar cada desenvolvedor gerar suas próprias chaves/CSRs localmente.

7) Integração com `traefik_portainer` (Docker Swarm)

No `traefik_portainer/compose-traefik-swarm.yml` monte o diretório `traefik_portainer/certs/local.dev` como `/certs/local.dev` no container (o compose de exemplo já faz isso).

Após gerar os certificados e o `fullchain`, atualize `traefik_portainer/config/traefik/tls.yml` para usar o `local.dev.fullchain.crt` e rode `docker service update --force traefik_traefik`.

---

Se quiser, eu posso gerar os certificados aqui neste ambiente e validar o acesso `https://portainer.local.dev:8443` com os comandos acima — quer que eu proceda com a instalação e geração dos certificados agora?

**Como executar o script de instalação (recomendo usar este script)**

1) Torne o script executável (opcional):

```bash
chmod +x scripts/setup-mkcert-localdev.sh
```

2) Execute o script (pode pedir `sudo` ao instalar pacotes):

```bash
# executar com bash
bash scripts/setup-mkcert-localdev.sh

# ou, se tornou executável
./scripts/setup-mkcert-localdev.sh
```

3) O que o script faz
- Detecta gerenciador de pacotes (`apt`, `pacman`, `apk`, `brew`, `snap`) e tenta instalar `mkcert` por lá.
- Se não houver pacote disponível, baixa o binário do release mais recente do GitHub para `$HOME/.local/bin`.
- Executa `mkcert -install`, gera `local.dev.crt` e `local.dev.key` e copia `rootCA.pem` para `traefik_portainer/certs/local.dev`.

4) Verificar arquivos gerados:

```bash
ls -l traefik_portainer/certs/local.dev
# deve listar: local.dev.crt  local.dev.key  local.dev.fullchain.crt  rootCA.pem
```

5) Teste rápido HTTPS (sem Traefik)

```bash
# iniciar servidor HTTPS simples na porta 8443
nohup openssl s_server -accept 8443 -cert traefik_portainer/certs/local.dev/local.dev.fullchain.crt -key traefik_portainer/certs/local.dev/local.dev.key -WWW &

# testar com curl (mapear hostname local para 127.0.0.1)
curl -vk --resolve portainer.local.dev:8443:127.0.0.1 https://portainer.local.dev:8443/ --cacert traefik_portainer/certs/local.dev/rootCA.pem
```

6) Observações
- O script pode pedir `sudo` se usar instalação via gerenciador de pacotes. Se preferir evitar `sudo`, use o fallback que baixa o binário (o script já faz isso como fallback).
- Não comite a chave privada (`traefik_portainer/certs/local.dev/local.dev.key`) no repositório.


```

