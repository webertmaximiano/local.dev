# Tutorial: Subindo o Serviço do MySQL no Kubernetes

Este tutorial guia você no processo de implantação de uma instância do MySQL no seu cluster Kubernetes local, usando os manifestos que criamos.

## Pré-requisitos

- Cluster Kubernetes em execução (por exemplo, via Docker Desktop).
- `kubectl` configurado para se comunicar com o seu cluster.

## Passo a Passo

### 1. Criação do Secret para a Senha

Por segurança, a senha do root do MySQL não deve ser colocada diretamente nos arquivos de manifesto. Em vez disso, usamos um `Secret` do Kubernetes para armazená-la de forma segura.

**Manifesto (`mysql-secret.yaml`):**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  ROOT_PASSWORD: bG9jYWxkZXY= # Senha 'localdev' codificada em Base64
```

**Aplique o manifesto:**

```bash
kubectl apply -f mysql/mysql-secret.yaml
```

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
kubectl apply -f mysql/mysql-pvc.yaml
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
kubectl apply -f mysql/mysql-deployment.yaml
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

Agora você pode usar seu cliente MySQL preferido para se conectar a `127.0.0.1:3306` com o usuário `root` e a senha `localdev`.
