# Tutorial: Subindo o Serviço do MySQL no Kubernetes

Este tutorial guia você no processo de implantação de uma instância do MySQL no seu cluster Kubernetes local, usando os manifestos que criamos.

## Pré-requisitos

- Cluster Kubernetes em execução (por exemplo, via Docker Desktop).
- `kubectl` configurado para se comunicar com o seu cluster.

## Passo a Passo

### 1. Criação do Secret para a Senha

Não versione senhas em YAML, mesmo quando `data` usa Base64: Base64 é apenas codificação. Crie um arquivo temporário protegido fora do repositório e use-o para criar o Secret:

```bash
secret_file=$(mktemp)
chmod 600 "$secret_file"
trap 'rm -f "$secret_file"' EXIT
${EDITOR:-vi} "$secret_file"
# No editor, informe uma única linha: ROOT_PASSWORD=<sua-senha-local>
kubectl create secret generic mysql-secret --from-env-file="$secret_file"
rm -f "$secret_file"
trap - EXIT
```

O arquivo temporário não deve ser copiado para o repositório. O manifesto `mysql-secret.yaml` foi removido porque continha uma credencial; o `.gitignore` bloqueia novos manifests `*-secret.yaml` e `*-secret.yml`. O `.gitignore` não remove arquivos que já estavam rastreados.

### 2. Criação do PersistentVolumeClaim (PVC)

Para garantir que os dados do MySQL persistam mesmo que o Pod seja reiniciado, precisamos de armazenamento persistente. O `PersistentVolumeClaim` (PVC) solicita um pedaço de armazenamento do Kubernetes.

**Manifesto (`mysql-pvc.yaml`):**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc-data
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: hostpath # Padrão no Docker Desktop
  resources:
    requests:
      storage: 5Gi
```

**Aplique o manifesto:**

```bash
kubectl apply -f kubernetes/workloads/databases/mysql/mysql-pvc.yaml
```

### 3. Implantação do MySQL (Deployment e Service)

Finalmente, vamos implantar o MySQL. O `Deployment` gerencia os Pods do MySQL, enquanto o `Service` expõe o banco de dados para outras aplicações dentro do cluster.

**Manifesto (`mysql-deployment.yaml`):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: ROOT_PASSWORD
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pvc-data
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  selector:
    app: mysql
  ports:
    - protocol: TCP
      port: 3306
      targetPort: 3306
```

**Aplique o manifesto:**

```bash
kubectl apply -f kubernetes/workloads/databases/mysql/mysql-deployment.yaml
```

### 4. Verificando a Implantação

Após alguns minutos (o download da imagem pode demorar), você pode verificar se o Pod do MySQL está em execução:

```bash
kubectl get pods -l app=mysql
```

A saída deve ser semelhante a esta:

```
NAME                     READY   STATUS    RESTARTS   AGE
mysql-77cf5898dd-wk4tt   1/1     Running   0          5m
```

## Conectando ao MySQL

Para se conectar ao banco de dados a partir de outro Pod no mesmo cluster, você pode usar o nome do serviço, `mysql`, como o host.

Para acesso externo ou para se conectar a partir da sua máquina local, você pode usar o `port-forward`:

```bash
kubectl port-forward svc/mysql 3306:3306
```

Agora use seu cliente MySQL para se conectar a `127.0.0.1:3306` com o usuário `root` e a senha escolhida ao criar o Secret. Não coloque essa senha em comandos salvos, manifests ou documentação.
