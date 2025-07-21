# Tutorial: Configurando Volumes para Desenvolvimento Local

Este tutorial aborda a configuração de volumes para desenvolvimento local, permitindo que você edite arquivos em sua máquina e veja as alterações refletidas instantaneamente em contêineres Docker ou pods Kubernetes. Isso é essencial para um fluxo de trabalho ágil e eficiente.

## Problemas Comuns e Soluções

Se você está tendo problemas com o mapeamento de diretórios, as causas mais comuns são:

*   **Permissões:** O usuário que executa o processo dentro do contêiner/pod pode não ter permissões de leitura/escrita no diretório mapeado do host. No Linux, isso geralmente envolve o UID/GID do usuário dentro do contêiner.
*   **Caminhos Incorretos:** Erros de digitação ou caminhos relativos/absolutos incorretos podem impedir o mapeamento.
*   **Especificidades do Docker Desktop (Windows/macOS):** Nestes sistemas, é necessário configurar os "Shared Drives" ou "File Sharing" nas configurações do Docker Desktop para que os diretórios do host sejam acessíveis aos contêineres.

## 1. Mapeamento de Volumes com Docker Compose (Bind Mounts)

Para aplicações Docker Compose, utilizamos `bind mounts` para mapear um diretório do seu host diretamente para um diretório dentro do contêiner. Isso é ideal para desenvolvimento, pois qualquer alteração no código-fonte local é imediatamente visível no contêiner.

### Exemplo de `docker-compose.yml`

Considere uma aplicação Node.js onde o código-fonte está na pasta `.` (raiz do projeto) e precisa ser montado em `/app` dentro do contêiner.

```yaml
version: '3.8'

services:
  minha-app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app # Mapeia o diretório atual do host para /app no contêiner
    working_dir: /app
    # Se houver problemas de permissão no Linux, você pode tentar:
    # user: "1000:1000" # Substitua pelo seu UID:GID
```

**Explicação:**

*   `- .:/app`: O ponto (`.`) representa o diretório atual onde o `docker-compose.yml` está localizado no seu host. `/app` é o caminho dentro do contêiner onde o diretório do host será montado.
*   `working_dir: /app`: Define o diretório de trabalho padrão dentro do contêiner.
*   `user: "1000:1000"`: Em sistemas Linux, se o processo dentro do contêiner tentar escrever no volume e o usuário padrão do contêiner não tiver permissão, você pode especificar o UID e GID do seu usuário no host para que as permissões se alinhem. Para descobrir seu UID e GID, use `id -u` e `id -g` no terminal.

## 2. Mapeamento de Volumes com Kubernetes (hostPath)

No Kubernetes, o `hostPath` permite que um pod acesse arquivos e diretórios do sistema de arquivos do nó onde o pod está sendo executado. É útil para desenvolvimento local com Docker Desktop, onde o "nó" é sua própria máquina.

### Exemplo de `Deployment` com `hostPath`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minha-app-k8s
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minha-app-k8s
  template:
    metadata:
      labels:
        app: minha-app-k8s
    spec:
      containers:
        - name: minha-app-k8s
          image: minha-app-image:latest # Sua imagem da aplicação
          ports:
            - containerPort: 3000
          volumeMounts:
            - name: app-code
              mountPath: /app # Caminho dentro do contêiner
      volumes:
        - name: app-code
          hostPath:
            path: /home/webert/local.dev/minha-app # Caminho ABSOLUTO no seu host
            type: DirectoryOrCreate # Garante que o diretório exista
```

**Explicação:**

*   `volumes.name: app-code`: Define um nome para o volume.
*   `hostPath.path: /home/webert/local.dev/minha-app`: **Este deve ser o caminho ABSOLUTO para o diretório do seu projeto no host.**
*   `hostPath.type: DirectoryOrCreate`: Garante que o diretório no host será criado se não existir.
*   `volumeMounts.name: app-code`: Referencia o volume definido.
*   `volumeMounts.mountPath: /app`: O caminho dentro do contêiner onde o volume será montado.

**Considerações Importantes para `hostPath`:**

*   **Caminho Absoluto:** Sempre use caminhos absolutos para `hostPath.path`. Caminhos relativos não funcionarão como esperado.
*   **Permissões:** Assim como no Docker Compose, problemas de permissão podem ocorrer. Certifique-se de que o processo dentro do contêiner tenha as permissões necessárias para o diretório mapeado no host.
*   **Portabilidade:** `hostPath` não é portátil para ambientes de produção com múltiplos nós, pois o diretório só existe no nó específico onde o pod está rodando. Para produção, use `PersistentVolumeClaims` com soluções de armazenamento de rede (NFS, Ceph, AWS EBS, etc.). Para desenvolvimento local, é perfeitamente aceitável.

## Solução de Problemas de Permissão (Linux)

Se você estiver no Linux e tiver problemas de permissão, tente as seguintes abordagens:

1.  **Verificar UID/GID:**
    ```bash
    id -u # Mostra seu User ID
    id -g # Mostra seu Group ID
    ```
    Use esses valores na configuração do `user` no `docker-compose.yml` ou, para Kubernetes, certifique-se de que o usuário dentro da imagem do contêiner tenha permissão para o diretório.

2.  **Alterar Permissões do Diretório (CUIDADO!):**
    Em último caso, você pode alterar as permissões do diretório no host, mas faça isso com cautela, pois pode comprometer a segurança.
    ```bash
    sudo chmod -R 777 /caminho/do/seu/projeto # Permissão total (não recomendado para produção)
    sudo chown -R seu_usuario:seu_grupo /caminho/do/seu/projeto # Mudar o proprietário
    ```

3.  **SELinux/AppArmor:** Em algumas distribuições Linux, SELinux ou AppArmor podem estar bloqueando o acesso. Verifique os logs do sistema (`journalctl -xe`) para ver se há mensagens relacionadas a eles.

Com este tutorial, você deve ser capaz de configurar volumes de forma eficaz para seu ambiente de desenvolvimento local, tanto com Docker Compose quanto com Kubernetes.
