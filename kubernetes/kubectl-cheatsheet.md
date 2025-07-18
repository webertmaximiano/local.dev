# Guia de Comandos Essenciais do `kubectl`

## 🚀 Introdução

Bem-vindo ao seu guia de referência rápida para o `kubectl`, a ferramenta de linha de comando indispensável para interagir com clusters Kubernetes. Pense nele como o seu "canivete suíço" para inspecionar, gerenciar e depurar suas aplicações na nuvem.

Este guia foi feito para ser um recurso prático. Ele não cobre todos os comandos existentes, mas foca nos **80% que você usará em 99% do tempo**, especialmente durante o desenvolvimento e aprendizado.

## 1. Conectando e Verificando o Cluster

Antes de mais nada, você precisa saber a qual cluster você está conectado.

### `kubectl config get-contexts`

*   **O que faz?** Lista todos os clusters que seu `kubectl` conhece (os "contextos").
*   **Quando usar?** Sempre que você não tiver certeza a qual cluster seus comandos estão sendo enviados (ex: Docker Desktop, Minikube, um cluster na nuvem).
*   **Exemplo:**
    ```bash
    kubectl config get-contexts
    # CURRENT   NAME             CLUSTER          AUTHINFO         NAMESPACE
    # *         docker-desktop   docker-desktop   docker-desktop
    ```
    O asterisco `*` indica o contexto ativo.

### `kubectl config use-context <context-name>`

*   **O que faz?** Muda o contexto ativo para outro cluster.
*   **Quando usar?** Quando você precisa alternar entre seu ambiente local e um ambiente de produção, por exemplo.
*   **Exemplo:**
    ```bash
    kubectl config use-context docker-desktop
    ```

## 2. Inspecionando Recursos (Os comandos de `get`)

Esta é a família de comandos que você mais usará. Eles são usados para **visualizar** os recursos que estão rodando no seu cluster.

### `kubectl get pods`

*   **O que faz?** Lista todos os Pods no namespace atual.
*   **Quando usar?** Para ver se sua aplicação está rodando, se reiniciou, ou se está com algum erro.

### `kubectl get services` (ou `svc`)

*   **O que faz?** Lista os serviços, que são os pontos de acesso internos para seus Pods.
*   **Quando usar?** Para encontrar o `CLUSTER-IP` de um serviço ou verificar as portas mapeadas.

### `kubectl get deployments` (ou `deploy`)

*   **O que faz?** Lista os Deployments, que gerenciam os Pods e suas réplicas.
*   **Quando usar?** Para verificar quantas réplicas da sua aplicação deveriam estar rodando e quantas estão prontas.

### `kubectl get ingresses` (ou `ing`)

*   **O que faz?** Lista as regras de Ingress, que expõem seus serviços para o mundo exterior.
*   **Quando usar?** Para ver quais hosts (domínios) estão mapeados para quais serviços.

### `kubectl get namespaces` (ou `ns`)

*   **O que faz?** Lista todos os Namespaces do cluster.
*   **Quando usar?** Para ter uma visão geral de como o cluster está organizado.

#### ✨ Dicas de Ouro para o `get`

*   **Ver em um namespace específico:** Adicione `-n <namespace>`.
    ```bash
    kubectl get pods -n monitoring-grafana
    ```
*   **Obter mais detalhes:** Adicione `-o wide` para ver mais informações, como o IP do Pod e em qual nó ele está rodando.
    ```bash
    kubectl get pods -o wide
    ```
*   **Ver tudo em um namespace:**
    ```bash
    kubectl get all -n <namespace>
    ```

## 3. Criando e Modificando Recursos

### `kubectl apply -f <arquivo.yaml>`

*   **O que faz?** Cria ou atualiza um recurso no Kubernetes a partir de um arquivo de manifesto YAML. É a forma **declarativa** e recomendada de gerenciar recursos.
*   **Quando usar?** Este é o seu comando principal para implantar qualquer coisa: um Deployment, um Service, um Ingress, etc.
*   **Exemplo:**
    ```bash
    kubectl apply -f /home/webert/local.dev/traefik/hello-world.yaml
    ```

### `kubectl create <recurso>`

*   **O que faz?** Cria um recurso de forma **imperativa** (dando uma ordem direta).
*   **Quando usar?** Útil para criar recursos simples rapidamente, sem a necessidade de um arquivo YAML.
*   **Exemplos:**
    ```bash
    # Criar um namespace
    kubectl create namespace meu-namespace

    # Criar um secret a partir de literais
    kubectl create secret generic meu-secret --from-literal=usuario=admin --from-literal=senha=12345
    ```

## 4. Debugging e Logs (Seus Comandos de "Socorro")

Quando as coisas dão errado, estes são seus melhores amigos.

### `kubectl logs <nome-do-pod>`

*   **O que faz?** Mostra os logs (a saída padrão) de um contêiner dentro de um Pod.
*   **Quando usar?** É a primeira coisa a se fazer quando um Pod não está se comportando como o esperado.
*   **Dicas:**
    *   Para seguir os logs em tempo real: `kubectl logs -f <nome-do-pod>`
    *   Se o Pod reiniciou, para ver os logs do contêiner anterior: `kubectl logs -p <nome-do-pod>`

### `kubectl describe pod <nome-do-pod>`

*   **O que faz?** Fornece uma descrição super detalhada de um Pod. Mostra seu estado, eventos, volumes, IPs, e por que ele pode estar falhando.
*   **Quando usar?** Quando um Pod está com status `Pending`, `Error`, ou `CrashLoopBackOff`. A seção `Events` no final da saída geralmente diz exatamente qual é o problema.
*   **Exemplo:**
    ```bash
    kubectl describe pod traefik-abcdef-12345
    ```

### `kubectl exec -it <nome-do-pod> -- <comando>`

*   **O que faz?** Executa um comando dentro de um contêiner que já está rodando. A flag `-it` torna a sessão interativa.
*   **Quando usar?** Para "entrar" em um contêiner e verificar o ambiente, ver arquivos, ou testar a conectividade de rede de dentro do Pod.
*   **Exemplo para abrir um shell:**
    ```bash
    kubectl exec -it meu-pod-12345 -- /bin/sh
    # (Se o /bin/sh não funcionar, tente /bin/bash)
    ```

## 5. Excluindo Recursos

### `kubectl delete -f <arquivo.yaml>`

*   **O que faz?** Exclui todos os recursos definidos em um arquivo YAML.
*   **Quando usar?** Para remover de forma limpa uma aplicação que você implantou com `kubectl apply`.
*   **Exemplo:**
    ```bash
    kubectl delete -f /home/webert/local.dev/traefik/hello-world.yaml
    ```

### `kubectl delete <recurso> <nome-do-recurso>`

*   **O que faz?** Exclui um recurso específico pelo nome.
*   **Quando usar?** Para remover rapidamente um único item.
*   **Exemplos:**
    ```bash
    kubectl delete pod meu-pod-12345
    kubectl delete service meu-servico
    kubectl delete namespace meu-namespace
    ```
