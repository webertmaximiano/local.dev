# Guia: Deploy de Nova Aplicação com Traefik no Ambiente Local

Este tutorial descreve o processo seguro para implantar uma **nova aplicação** no ambiente de desenvolvimento local, expondo-a através de um domínio virtual com Traefik.

O objetivo principal é garantir que novas aplicações possam ser adicionadas **sem alterar ou quebrar a configuração existente** do Traefik, Prometheus ou Grafana.

## Princípios Orientadores (Regras de Ouro)

Qualquer interação, especialmente por uma IA, **DEVE** seguir estas regras:

1.  **NÃO ALTERE A INFRAESTRUTURA EXISTENTE:** Os arquivos de configuração do Helm para Traefik, Prometheus e Grafana (`traefik-helm-values.yaml`, `prometheus-values.yaml`, `grafana-values.yaml`) são considerados **imutáveis**. Não os modifique para adicionar novas aplicações.
2.  **ISOLE AS NOVAS APLICAÇÕES:** Cada nova aplicação deve ter seu próprio arquivo de manifesto YAML (Deployment, Service, Ingress). Isso mantém as configurações organizadas e independentes.
3.  **REUTILIZE O TLS EXISTENTE:** Para certificados TLS, sempre reutilize o Secret `local-dev-tls` que já está configurado para os domínios locais. Não crie novos Secrets TLS para cada aplicação.
4.  **SIGA O PADRÃO DE INGRESS:** Use as anotações padrão do Traefik para expor o serviço através da entrypoint `websecure`.

---

## Passo a Passo: Deploy da Aplicação `estouon.dev`

Vamos usar uma aplicação de exemplo chamada `whoami` para demonstrar o processo. Ela simplesmente exibe informações sobre a requisição recebida.

### Passo 1: Criar o Manifesto da Aplicação

Crie um novo arquivo, por exemplo, `estouon-dev-deployment.yaml`, com o seguinte conteúdo. Você pode salvá-lo na raiz do projeto ou em um diretório de aplicações.

```yaml
# estouon-dev-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: estouon-deployment
  labels:
    app: estouon
spec:
  replicas: 1
  selector:
    matchLabels:
      app: estouon
  template:
    metadata:
      labels:
        app: estouon
    spec:
      containers:
        - name: whoami
          image: "traefik/whoami" # Imagem de exemplo que responde a requisições HTTP
          ports:
            - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: estouon-service
spec:
  selector:
    app: estouon
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: estouon-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    # Nenhuma anotação de middleware de autenticação é necessária aqui, a menos que a app exija.
spec:
  ingressClassName: traefik
  rules:
    - host: "estouon.dev"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: estouon-service
                port:
                  number: 80
  tls:
    - hosts:
        - "estouon.dev"
      secretName: local-dev-tls # MUITO IMPORTANTE: Reutilize o secret existente!
```

### Passo 2: Adicionar o Domínio ao `/etc/hosts`

Para que seu computador local consiga resolver o domínio `estouon.dev`, adicione a seguinte linha ao seu arquivo `/etc/hosts`:

```
127.0.0.1 estouon.dev
```

### Passo 3: Aplicar o Manifesto

Execute o seguinte comando no seu terminal para criar os recursos no Kubernetes:

```bash
kubectl apply -f estouon-dev-deployment.yaml
```

### Passo 4: Verificar e Testar

Verifique se o pod está rodando:

```bash
kubectl get pods -l app=estouon
# Deverá ver um pod com o status '''Running'''
```

Agora, acesse **`https://estouon.dev`** no seu navegador. Você deverá ver a página da aplicação `whoami`.

---

## Trabalhando com Subdomínios Curinga (`*.estouon.dev`)

Se você precisa que vários subdomínios (`app1.estouon.dev`, `api.estouon.dev`, etc.) apontem para o mesmo serviço ou para serviços diferentes, você pode usar regras de Ingress com curinga.

**Importante:** O certificado TLS no Secret `local-dev-tls` **deve ser válido** para o domínio curinga (`*.estouon.dev`). Se não for, ele precisará ser recriado para incluir este Host.

Para um subdomínio específico, como `api.estouon.dev`, a regra no Ingress seria:

```yaml
# ... (dentro do seu Ingress)
  rules:
    - host: "api.estouon.dev"
      http:
# ... (resto da configuração)
  tls:
    - hosts:
        - "api.estouon.dev"
      secretName: local-dev-tls
```

Para uma regra curinga que captura todos os subdomínios:

```yaml
# ... (dentro do seu Ingress)
  rules:
    - host: "*.estouon.dev"
      http:
# ... (resto da configuração)
  tls:
    - hosts:
        - "*.estouon.dev"
      secretName: local-dev-tls
```

Lembre-se de adicionar cada subdomínio novo ao seu arquivo `/etc/hosts`.
