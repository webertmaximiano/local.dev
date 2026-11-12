# CI/CD e GitOps para iniciantes

Neste tutorial você vai acompanhar uma mudança desde o código até um cluster Kubernetes. Primeiro, o GitHub Actions verifica o projeto e cria uma imagem. Depois, uma mudança revisada no repositório de configuração pede ao Argo CD para atualizar o cluster.

O exercício é opcional e avançado em relação ao laboratório Docker Swarm padrão deste repositório. Para aprender Argo CD, você pode usar um cluster Kubernetes local; uma VPS não é obrigatória. Argo CD precisa conseguir ler o repositório Git e controlar o cluster onde está instalado. Não precisa expor o cluster à Internet só para o GitHub Actions falar com ele.

## O que significam CI, CD e GitOps?

- **Integração contínua (CI):** cada alteração é verificada automaticamente, por exemplo com lint, build e testes.
- **Entrega contínua:** depois das verificações, uma versão pronta fica disponível para implantação. A aprovação para produção pode continuar manual.
- **Implantação contínua:** a implantação também ocorre automaticamente depois dos controles definidos pela equipe.
- **GitOps:** os arquivos versionados no Git descrevem o estado desejado do ambiente. O Argo CD compara esses arquivos com o cluster e sincroniza as diferenças.

Neste exercício, o Actions **não acessa o cluster**. Ele testa o código e publica uma imagem. Você atualiza a versão da imagem no repositório GitOps; o Argo CD percebe o commit nesse repositório e sincroniza o cluster. Publicar uma nova imagem, por si só, não faz o Argo CD implantá-la.

## Antes de começar

Você precisa de:

- Uma conta e um repositório GitHub onde possa criar workflows.
- Uma aplicação Node.js com `package.json`, `package-lock.json`, scripts `lint` e `build`, e um `Dockerfile` de produção na raiz.
- Git, Docker e noções básicas de Kubernetes.
- Um cluster Kubernetes local ou remoto, apenas para a parte opcional do Argo CD.

O exemplo usa Node.js 24. Se seu projeto usa outra linguagem, substitua as etapas `npm` pelos comandos de verificação próprios dele. O arquivo de lock (`package-lock.json`) deve ser versionado para que `npm ci` instale as dependências registradas no projeto. Se o `package.json` tiver um script `test`, inclua também um passo `run: npm test` no job `verify`; não adicione esse comando se o script não existir.

## 1. CI: verificar o código em cada pull request

Crie `.github/workflows/ci-image.yml` no repositório da aplicação. O workflow abaixo roda lint e build em pull requests e em pushes para `main`. Só publica a imagem depois de um push em `main` e se as verificações passarem.

```yaml
name: Verificar e publicar imagem

on:
  pull_request:
  push:
    branches: [main]

# Padrão restrito. Cada job declara permissões adicionais somente quando precisa.
permissions:
  contents: read

jobs:
  verify:
    name: Lint e build
    runs-on: ubuntu-latest
    steps:
      - name: Baixar o código
        uses: actions/checkout@v7

      - name: Preparar Node.js
        uses: actions/setup-node@v7
        with:
          node-version: 24
          cache: npm

      - name: Instalar dependências do lockfile
        run: npm ci

      - name: Verificar estilo e erros comuns
        run: npm run lint

      - name: Gerar o build
        run: npm run build

  publish:
    name: Publicar imagem no GHCR
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    needs: verify
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - name: Baixar o código
        uses: actions/checkout@v7

      - name: Preparar Docker Buildx
        uses: docker/setup-buildx-action@v4

      - name: Entrar no GitHub Container Registry
        uses: docker/login-action@v4
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Criar nome e tag da imagem
        id: meta
        uses: docker/metadata-action@v6
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha,format=long

      - name: Construir e publicar a imagem
        uses: docker/build-push-action@v7
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

### Como ler esse workflow

- `on` diz quando executar: em pull requests e em pushes para `main`.
- `verify` executa lint e build. Um pull request de um fork também pode executar essas verificações, mas não recebe permissão para publicar imagens.
- `needs: verify` impede a publicação se as verificações falharem.
- `if` restringe a publicação a pushes para `main`; o workflow não publica imagens a partir de cada pull request.
- `GITHUB_TOKEN` é criado pelo GitHub para a execução do workflow. `packages: write` permite publicar no GHCR. Não crie um token pessoal para este caso.
- A tag `sha-...` identifica o commit que produziu a imagem. Ela permite descobrir e implantar a versão exata; evite usar `latest` como referência de implantação.

Esse exemplo supõe que `npm run lint`, `npm run build` e o `Dockerfile` existam na raiz. Para associar o pacote ao repositório, inclua no `Dockerfile` um label com a URL do projeto (substitua os nomes de exemplo):

```dockerfile
LABEL org.opencontainers.image.source="https://github.com/USUARIO/REPOSITORIO"
```

Confira também **Settings → Actions → General** e a visibilidade do pacote no GHCR. Pacotes publicados pela primeira vez podem ficar privados. Se a publicação for recusada, confira se a política do repositório ou da organização permite a permissão `packages: write`; não substitua o `GITHUB_TOKEN` por um token pessoal sem necessidade. Um cluster que precise baixar uma imagem privada requer uma credencial de leitura configurada como `imagePullSecret`; não coloque essa credencial no repositório.

As versões das Actions neste exemplo usam tags principais para facilitar o aprendizado; confira as versões atuais nas páginas oficiais antes de reutilizar o exemplo. Em repositórios de produção, siga a política de segurança da equipe e fixe cada Action a um SHA completo revisado. A documentação do GitHub recomenda permissões mínimas para `GITHUB_TOKEN` e descreve o risco de executar Actions de terceiros. Evite `pull_request_target` para executar código vindo de pull requests: esse evento pode dar ao workflow acesso privilegiado a secrets e permissões.

## 2. Conferir a imagem publicada

Depois que o push para `main` passar pelo workflow:

1. Abra a aba **Actions** do repositório e confirme que os jobs `verify` e `publish` terminaram com sucesso.
2. Abra a seção **Packages** do perfil ou da organização e localize a imagem.
3. Anote a tag `sha-...` gerada para o commit. A imagem terá o formato `ghcr.io/USUARIO/REPOSITORIO:sha-TAG`.

Para uma atividade pública, você pode tornar a imagem de demonstração pública nas configurações do pacote. Faça isso somente se a imagem e o código puderem ser distribuídos publicamente. Imagens privadas exigem que o cluster tenha autorização para baixá-las. O GHCR recomenda o label `org.opencontainers.image.source` no `Dockerfile` para associar o pacote ao repositório.

## 3. GitOps: registrar a implantação desejada

Mantenha os manifestos Kubernetes em um repositório GitOps. Para um exercício simples, esse repositório pode ser público e separado do código da aplicação. Não coloque nele senhas, tokens, chaves privadas, arquivos `.env` ou valores secretos. Um Kubernetes `Secret` comum contém dados codificados em Base64; isso não os torna seguros para publicação.

Depois que o Actions publicar uma imagem, altere o campo `image` no Deployment do repositório GitOps para a tag `sha-...` correspondente:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minha-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minha-app
  template:
    metadata:
      labels:
        app: minha-app
    spec:
      containers:
        - name: minha-app
          image: ghcr.io/USUARIO/REPOSITORIO:sha-TAG_DO_COMMIT
          ports:
            - containerPort: 8080
```

Substitua usuário, repositório, tag e porta pelos valores reais da aplicação. Faça commit dessa alteração e abra um pull request no repositório GitOps. Após a revisão e integração em `main`, o Argo CD poderá sincronizar o estado descrito no Git com o cluster.

Essa etapa é intencionalmente explícita: o workflow de aplicação **não recebe permissão de escrita** no repositório GitOps. Mais tarde, uma equipe pode automatizar a criação de um pull request de atualização de imagem, mas isso exige permissões e controles próprios. Não dê a um workflow de build acesso amplo para alterar outro repositório ou implantar diretamente no cluster.

## 4. Instalar e acessar Argo CD no cluster de estudo

Argo CD consome memória e CPU. Em um computador limitado, deixe-o desligado quando não estiver estudando essa parte. Para o exercício, use os manifests oficiais da versão estável atual. Para uma instalação de produção, escolha e registre uma versão específica seguindo o [guia oficial de instalação](https://argo-cd.readthedocs.io/en/stable/getting_started/):

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

Para a prática local, encaminhe a interface apenas para o próprio computador. Mantenha este comando aberto em um terminal:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Acesse `https://localhost:8080` no navegador. Instale também a [CLI do Argo CD](https://argo-cd.readthedocs.io/en/stable/cli_installation/) e, em outro terminal, obtenha a senha inicial:

```bash
argocd admin initial-password -n argocd
```

Mantenha a senha apenas no seu terminal. Faça login pela CLI; ela solicitará a senha sem colocá-la no comando:

```bash
argocd login localhost:8080 --insecure --username admin
argocd account update-password
kubectl delete secret argocd-initial-admin-secret -n argocd
```

O primeiro comando da CLI usa `--insecure` porque a instalação local tem um certificado autoassinado. Não use essa opção como configuração de um serviço publicado. Não compartilhe a senha nem exponha a interface administrativa diretamente à Internet.

## 5. Registrar a aplicação no Argo CD

Para o primeiro exercício, use um repositório GitOps público que contenha apenas manifests não secretos. Um repositório público não precisa de usuário, token ou chave para ser lido pelo Argo CD.

Salve o manifesto abaixo como `argocd-application.yaml`, substitua a URL e o caminho, e aplique-o com `kubectl`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: minha-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/USUARIO/MEU-REPOSITORIO-GITOPS.git
    targetRevision: main
    path: k8s-manifests/minha-app
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated: {}
```

```bash
kubectl apply -f argocd-application.yaml
```

O Argo CD passa a observar o caminho indicado. Quando o commit com a nova tag de imagem chega à branch `main` do repositório GitOps, o Argo CD vê a diferença e sincroniza a aplicação. Por padrão, a sincronização automática não remove recursos que foram apagados do Git. Estude opções como `prune` e `selfHeal` antes de habilitá-las: elas mudam como o cluster reage a remoções e alterações feitas fora do Git.

Para um repositório GitOps privado, configure o acesso pelo mecanismo de credenciais do Argo CD usando uma chave de deploy ou integração aprovada pela equipe. Não passe token em argumentos como `--password`, pois ele pode ficar no histórico do terminal ou na lista de processos. Siga a [documentação de conexão de repositórios](https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/).

## Resumo do fluxo

```text
Pull request da aplicação
        ↓
GitHub Actions: lint e build
        ↓ após merge em main
GitHub Actions: publica imagem identificada pelo commit no GHCR
        ↓ atualização revisada no repositório GitOps
Argo CD: sincroniza os manifests com o cluster Kubernetes
```

CI valida e empacota a aplicação. O repositório GitOps registra qual versão deve rodar. Argo CD aplica esse estado ao cluster. Essa separação dá um histórico revisável de implantação e evita que o workflow de build precise de acesso direto à infraestrutura.

## Referências oficiais

- [GitHub Actions: segurança de uso](https://docs.github.com/en/actions/reference/security/secure-use)
- [`GITHUB_TOKEN` e permissões em workflows](https://docs.github.com/en/actions/tutorials/authenticate-with-github_token)
- [Publicar imagens no GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Argo CD: instalação e primeiros passos](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Argo CD: sincronização automática](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/)
