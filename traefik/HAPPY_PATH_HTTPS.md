Guia rápido: HTTPS local com mkcert para local.dev e subdomínios
=============================================================

Resumo
-----
- Gerar certificados locais confiáveis por mkcert.
- Não comitar chaves privadas no repositório (`traefik_portainer/certs/` ignorado).
- Usar `fullchain` (cert + CA) montado no Traefik e instalar a CA nos navegadores/hosts.

Passo a passo (caminho feliz)
-----------------------------
1. Instale `mkcert` na sua máquina (Linux):

   sudo apt install libnss3-tools
   curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
   chmod +x mkcert-v*-linux-amd64 && sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert

2. Instale a CA local no sistema e browsers:

   mkcert -install

3. Gere certificados para `traefik.local.dev` e subdomínios (ex.: todos `*.local.dev`):

   mkdir -p traefik_portainer/certs/local.dev
   mkcert -cert-file traefik_portainer/certs/local.dev/local.dev.fullchain.crt \
          -key-file  traefik_portainer/certs/local.dev/local.dev.key \
          traefik.local.dev "*.local.dev"

   Observação: o `fullchain.crt` deve incluir o certificato do site seguido pela CA.

4. Assegure o `tls.yml` do Traefik aponte para `/certs/local.dev.fullchain.crt` e `/certs/local.dev.key`.

5. Redeploy da stack Traefik (no Swarm):

   docker stack deploy -c traefik_portainer/compose-traefik-swarm.yml traefik

6. Teste local:

   curl -vk https://traefik.local.dev

Se o navegador mostrar HSTS/ERR_CERT_AUTHORITY_INVALID
----------------------------------------------------
- Feche e reabra o Chrome após `mkcert -install`.
- No Chrome: vá em `chrome://net-internals/#hsts` e limpe o HSTS para `traefik.local.dev` se necessário.

Boas práticas
-------------
- Não comitar `local.dev.key` nem `local.dev.fullchain.crt` em repositórios públicos.
- Adicionar `traefik_portainer/certs/` ao `.gitignore` (já configurado).
- Para ambientes compartilhados, gere novos certificados em cada máquina ou distribua a CA raiz com segurança.

Mais recursos
-------------
- mkcert: https://github.com/FiloSottile/mkcert
- Traefik TLS docs: https://doc.traefik.io/traefik/https/
