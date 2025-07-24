# Tutorial: Adicionando o Redis ao seu Ambiente de Desenvolvimento

O Redis é um banco de dados em memória de alto desempenho, frequentemente usado para cache, gerenciamento de sessões, filas e como um message broker. Este tutorial irá guiá-lo para adicionar um serviço Redis ao seu cluster Kubernetes local.

## 1. O Manifesto `redis-deployment.yaml`

O arquivo `redis-deployment.yaml` contém dois recursos principais do Kubernetes:

- **Deployment**: Garante que uma réplica (um Pod) do Redis esteja sempre em execução. Usamos a imagem `redis:7-alpine`, que é leve e otimizada.
- **Service**: Expõe o Redis dentro do cluster Kubernetes com um nome de serviço (DNS) estável, `redis`. Qualquer outra aplicação dentro do mesmo cluster pode se conectar ao Redis usando o host `redis` e a porta `6379`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  selector:
    app: redis
  ports:
    - protocol: TCP
      port: 6379
      targetPort: 6379
```

## 2. Aplicando o Manifesto

Com seu ambiente Kubernetes em execução, aplique o manifesto para criar os recursos do Redis:

```bash
kubectl apply -f redis/redis-deployment.yaml
```

## 3. Verificando a Instalação

Verifique se o Pod do Redis está em execução:

```bash
kubectl get pods
```

Você deverá ver um pod com o nome semelhante a `redis-xxxxxxxxxx-xxxxx` com o status `Running`.

Verifique também se o serviço foi criado:

```bash
kubectl get service redis
```

## 4. Conectando sua Aplicação (Ex: Laravel)

Na configuração da sua aplicação (por exemplo, no arquivo `.env` do Laravel), você pode agora apontar para o Redis usando o nome do serviço como host:

```ini
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
```

## 5. Acessando o Redis Localmente (Opcional)

Se precisar acessar o Redis diretamente da sua máquina local (fora do cluster) para depuração, você pode usar o `port-forward`, assim como fizemos com o MySQL:

```bash
kubectl port-forward service/redis 6379:6379
```

Agora, qualquer cliente Redis na sua máquina pode se conectar a `localhost:6379`.
