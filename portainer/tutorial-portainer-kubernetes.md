
# Tutorial: Implantando o Portainer no Kubernetes com Traefik

Este tutorial guia você na implantação do Portainer CE (Community Edition) em seu cluster Kubernetes local, expondo-o de forma segura com HTTPS através do Traefik.

## Pré-requisitos

*   Um ambiente Kubernetes local em funcionamento.
*   Traefik instalado e configurado como Ingress Controller, conforme o tutorial `traefik/tutorial-kubernetes-traefik.md`.
*   O domínio `portainer.local.dev` adicionado ao seu arquivo `/etc/hosts`, apontando para `127.0.0.1`.

## Passo 1: Aplicar os Manifestos do Portainer

Nesta pasta, temos dois arquivos que definem como o Portainer deve ser executado e exposto:

1.  `portainer-deployment.yaml`: Cria o `Deployment` que gerencia o pod do Portainer e o `Service` que o expõe internamente no cluster.
2.  `portainer-ingressroute.yaml`: Cria o `IngressRoute` que instrui o Traefik a direcionar o tráfego de `portainer.local.dev` para o serviço do Portainer, utilizando nosso certificado TLS.

Para implantar o Portainer, aplique ambos os arquivos com `kubectl`:

```bash
kubectl apply -f /home/webert/local.dev/portainer/portainer-deployment.yaml
kubectl apply -f /home/webert/local.dev/portainer/portainer-ingressroute.yaml
```

## Passo 2: Verificar a Implantação

Após alguns instantes, o pod do Portainer estará em execução. Você pode verificar seu status com o seguinte comando:

```bash
kubectl get pods -l app=portainer
```

A saída deve mostrar o pod com o status `Running`.

## Passo 3: Acessar o Portainer

Abra seu navegador e acesse:

**https://portainer.local.dev**

Como estamos usando um certificado TLS gerado pelo `mkcert`, seu navegador confiará na conexão.

Na primeira vez que você acessar, o Portainer solicitará que você crie um usuário administrador. Defina seu nome de usuário e senha e prossiga.

## Passo 4: Conectar ao Ambiente Kubernetes

Após o login, o Portainer apresentará uma tela para adicionar um ambiente. Selecione a opção **Kubernetes** e escolha a opção para se conectar ao cluster onde o Portainer está rodando (geralmente a opção padrão).

Clique em **Connect** e pronto! Você agora pode gerenciar seu cluster Kubernetes através da interface visual do Portainer.
