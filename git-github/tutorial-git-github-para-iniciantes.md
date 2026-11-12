# Git e GitHub: primeiros passos com segurança

Este tutorial acompanha você desde a configuração inicial até a proposta de uma mudança por *pull request*. Os comandos funcionam no Linux, macOS e Git Bash. No VS Code, abra **Terminal → Novo Terminal** e entre na pasta onde quer trabalhar.

## Git e GitHub: qual é a diferença?

- **Git** registra versões do projeto no seu computador. Cada registro é um *commit*.
- **GitHub** hospeda repositórios Git na internet e oferece ferramentas de colaboração, revisão e automação.
- **Repositório** é o projeto e seu histórico.
- **Branch** é uma linha de trabalho isolada, útil para desenvolver uma mudança sem mexer diretamente na versão principal.
- **Pull request (PR)** é uma proposta para revisar e integrar uma branch no GitHub.

## 1. Instalar e configurar o Git

Instale o Git seguindo as instruções do [site oficial](https://git-scm.com/downloads). Confira se está disponível:

```bash
git --version
```

Configure o nome e o e-mail que serão registrados nos seus commits:

```bash
git config --global user.name "Seu nome"
git config --global user.email "seu-email-verificado@example.com"
```

Esses dados identificam quem criou o commit; **não são seu usuário e senha de acesso ao GitHub**. O GitHub usa o e-mail do commit para associar contribuições à sua conta. Se preferir não publicar seu e-mail pessoal, obtenha seu endereço `noreply` em GitHub → **Settings → Emails** e use-o aqui. Confira os valores configurados:

```bash
git config --global user.name
git config --global user.email
```

A opção `--global` aplica esses dados a todos os repositórios deste computador. Para configurar uma identidade diferente só no projeto atual, entre na pasta dele e use `git config user.name "Seu nome"` e `git config user.email "endereco@example.com"` sem `--global`.

## 2. Autenticar no GitHub pelo terminal

O GitHub não aceita a senha da sua conta para `git push` e `git pull` por HTTPS. Para começar, recomendamos o **GitHub CLI (`gh`)**, que abre o navegador para você entrar e configura o acesso do Git:

1. Instale o [GitHub CLI](https://cli.github.com/).
2. No terminal, execute:

   ```bash
   gh auth login
   ```

3. Escolha `GitHub.com`, `HTTPS` e a opção para autenticar o Git com sua conta. Siga o link ou código exibido para concluir no navegador.
4. Confira a autenticação:

   ```bash
   gh auth status
   ```

Depois disso, `git push` e `git pull` usam a credencial guardada pelo GitHub CLI e pelo gerenciador de credenciais configurado. Outra opção é usar uma chave SSH; siga o [guia oficial de configuração de SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

**Nunca cole um token ou senha em um comando, arquivo do projeto, issue, pull request ou conversa.** Se uma instrução pedir uma senha para HTTPS, não use a senha da conta: autentique com `gh` ou configure um gerenciador de credenciais. Tokens pessoais são uma alternativa técnica para casos específicos; devem ter o menor acesso necessário e ser tratados como senhas.

## 3. Criar seu primeiro repositório

### Criar o projeto no computador

Os comandos abaixo criam uma pasta, iniciam um repositório cuja branch principal se chama `main` e criam um arquivo de exemplo:

```bash
mkdir meu-primeiro-projeto
cd meu-primeiro-projeto
git init -b main
echo "Olá, Git e GitHub!" > README.md
```

Veja o que o Git encontrou:

```bash
git status
```

Adicione somente o arquivo desejado à área de preparação (*staging*), confira o conteúdo que entrará no commit e então registre a mudança:

```bash
git add README.md
git diff --staged
git commit -m "Adiciona o README inicial"
```

`git add` prepara arquivos; `git commit` grava um ponto no histórico local. Se o diff mostrar algo inesperado, corrija ou remova esse arquivo da preparação antes de continuar.

### Criar o repositório no GitHub e publicar

1. Entre no GitHub e escolha **New repository**.
2. Dê um nome e escolha a visibilidade. Um repositório **público** pode ser visto por qualquer pessoa; um **privado** limita quem pode acessá-lo. Antes de publicar código de aula ou trabalho, confira se você tem autorização e se não há dados privados.
3. Para este exercício, deixe desmarcadas as opções de criar README, `.gitignore` ou licença. Assim, o repositório remoto começa vazio e não cria um histórico separado do local.
4. Copie a URL HTTPS do repositório e conecte-a ao projeto. Substitua `SEU_USUARIO` pelo seu nome no GitHub:

   ```bash
   git remote add origin https://github.com/SEU_USUARIO/meu-primeiro-projeto.git
   git remote -v
   git push -u origin main
   ```

`origin` é o apelido mais comum para o repositório remoto. `-u` associa sua branch local `main` à branch remota; nas próximas vezes, basta `git push` ou `git pull`.

## 4. Baixar um projeto que já existe

`git clone` cria uma pasta com o projeto e seu histórico. Para praticar com este repositório:

```bash
git clone https://github.com/webertmaximiano/local.dev.git
cd local.dev
```

Projetos públicos podem ser clonados sem autenticação. Para enviar alterações, você precisa ter permissão de escrita ou trabalhar em um *fork* (uma cópia do repositório na sua conta).

## 5. Fluxo diário: revisar, preparar, registrar e enviar

Antes de começar em um projeto compartilhado, atualize sua branch principal:

```bash
git switch main
git pull --ff-only
```

`--ff-only` atualiza quando sua branch pode avançar sem criar um merge automático. Se o comando falhar, pare e confira o estado com `git status`; não tente resolver usando `push --force`.

Depois de editar os arquivos:

```bash
git status
git diff
git add caminho/do/arquivo
git diff --staged
git commit -m "Descreve a mudança"
git push
```

Substitua `caminho/do/arquivo` pelo nome real do arquivo. O `git diff` mostra alterações ainda não preparadas; `git diff --staged` mostra o que será gravado no próximo commit. Prefira adicionar arquivos específicos em vez de `git add .`, para não incluir acidentalmente arquivos locais, dependências ou segredos.

Se `git push` for recusado porque o remoto tem mudanças novas, não force o envio. Confira `git status`, atualize com `git pull --ff-only` se sua branch estiver apenas atrasada e leia a mensagem do Git. Se ele indicar divergência ou conflito, peça ajuda antes de escolher merge ou rebase.

## 6. Branches e pull requests

Para uma mudança que outras pessoas devem revisar, crie uma branch a partir da versão atualizada de `main`:

```bash
git switch main
git pull --ff-only
git switch -c docs/melhora-tutorial
```

O nome `docs/melhora-tutorial` é um exemplo; use um nome curto que indique o assunto. Edite os arquivos e faça commits nessa branch:

```bash
git status
git add caminho/do/arquivo
git diff --staged
git commit -m "Melhora o tutorial de instalação"
git push -u origin docs/melhora-tutorial
```

No GitHub, abra o repositório, escolha a branch publicada e clique em **Compare & pull request** (ou **New pull request**). Confira se a branch de destino é `main`, escreva o que mudou e por quê, e crie o pull request. A equipe pode comentar, pedir ajustes e verificar os controles automáticos antes de aprovar e integrar a mudança.

Se você não tem permissão de escrita no repositório, crie um *fork* e publique sua branch nele; o pull request propõe as mudanças do seu fork para o repositório original. Veja o [guia oficial de pull requests](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests).

Após a mudança ser integrada, atualize `main` e remova a branch local já concluída:

```bash
git switch main
git pull --ff-only
git branch -d docs/melhora-tutorial
```

## 7. Ver o histórico

```bash
git log --oneline --decorate -10
```

Esse comando mostra os dez commits mais recentes de forma compacta. Pressione `q` se o Git abrir um visualizador paginado.

## 8. Ignorar arquivos locais com `.gitignore`

Crie um arquivo chamado `.gitignore` na raiz do projeto. Ele informa ao Git quais arquivos locais não devem ser adicionados por engano. Exemplo inicial:

```gitignore
# Dependências e saídas geradas
node_modules/
vendor/
dist/
build/

# Logs e temporários
*.log
*.tmp
*.bak

# Configuração local e segredos
.env
.env.*
!.env.example
*.key
*.key.pem
```

O arquivo `.env.example` deve conter apenas nomes de variáveis e valores fictícios, nunca credenciais reais. Ajuste as regras ao seu projeto: `.gitignore` não é uma lista universal nem uma barreira de segurança.

Confira `git status` antes de cada commit. Se um arquivo que deveria ser ignorado já estiver sendo rastreado, `.gitignore` não o remove do histórico. Peça orientação antes de removê-lo do índice. Se uma senha, token ou chave privada já foi enviada ao GitHub, considere-a comprometida: revogue ou troque a credencial imediatamente. Apagar o arquivo em um commit posterior não apaga a cópia dos commits anteriores.

## 9. Comandos úteis de consulta

```bash
git status                 # Estado dos arquivos e da branch
git branch --show-current  # Branch atual
git remote -v              # Endereços dos repositórios remotos
git diff                   # Mudanças ainda não preparadas
git diff --staged          # Mudanças preparadas para o próximo commit
git log --oneline -10      # Histórico recente
```

## Onde consultar mais

- [Livro oficial Pro Git](https://git-scm.com/book/pt-br/v2)
- [GitHub CLI: início rápido](https://docs.github.com/en/github-cli/github-cli/quickstart)
- [Autenticação no GitHub](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-authentication)
- [E-mails de commit e privacidade](https://docs.github.com/en/account-and-profile/reference/email-addresses-reference)
- [Pull requests](https://docs.github.com/en/pull-requests/get-started)
