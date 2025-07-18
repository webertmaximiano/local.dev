# Guia Essencial: Git e GitHub para Iniciantes

Bem-vindo à "Fase 0" do seu aprendizado! O Git e o GitHub são ferramentas indispensáveis para qualquer desenvolvedor moderno. Eles permitem que você controle as versões do seu código, colabore com outras pessoas e construa um portfólio.

## 🚀 O que é Git?

**Git** é um sistema de controle de versão distribuído. Pense nele como uma máquina do tempo para o seu código. Ele registra todas as alterações que você faz nos seus arquivos, permitindo que você volte a versões anteriores, compare mudanças e trabalhe em diferentes funcionalidades sem bagunçar o projeto principal.

## 🌐 O que é GitHub?

**GitHub** é uma plataforma de hospedagem de código-fonte baseada em nuvem que usa o Git. É como uma rede social para desenvolvedores, onde você pode armazenar seus projetos (repositórios), colaborar com outros, revisar código e mostrar seu trabalho para o mundo.

## 🛠️ Pré-requisitos

*   Ter uma conta no [GitHub](https://github.com/).
*   Ter o Git instalado na sua máquina. Se você não tem, siga as instruções em [git-scm.com/downloads](https://git-scm.com/downloads).

## 1. Configuração Inicial do Git

Após instalar o Git, você precisa configurar seu nome de usuário e e-mail. Isso é importante porque cada "commit" (salvamento de alterações) no Git é associado a essas informações.

```bash
git config --global user.name "Seu Nome Completo"
git config --global user.email "seu.email@example.com"
```

Para verificar se a configuração foi aplicada:

```bash
git config --list
```

## 2. Criando seu Primeiro Repositório (Projeto)

Um repositório (ou "repo") é onde seu projeto e todo o seu histórico de versões são armazenados.

### Opção A: Criar um Repositório Local e Conectar ao GitHub

1.  **Crie uma pasta para o seu projeto:**
    ```bash
mkdir meu-primeiro-projeto
cd meu-primeiro-projeto
    ```
2.  **Inicialize o Git na pasta:**
    ```bash
git init
    ```
    Isso cria uma pasta oculta `.git` que o Git usará para rastrear as alterações.
3.  **Crie um arquivo de exemplo:**
    ```bash
echo "Olá, Git e GitHub!" > README.md
    ```
4.  **Adicione o arquivo ao "staging area" (área de preparação):**
    ```bash
git add README.md
    ```
    O `git add` informa ao Git quais arquivos você quer incluir no próximo salvamento.
5.  **Faça seu primeiro commit (salvamento):**
    ```bash
git commit -m "Primeiro commit: Adiciona README.md"
    ```
    O `-m` é para a mensagem do commit, que deve descrever as alterações feitas.
6.  **Crie um repositório vazio no GitHub:**
    *   Vá para o GitHub, clique em `+` (canto superior direito) -> `New repository`.
    *   Dê um nome (ex: `meu-primeiro-projeto`).
    *   **Não** marque a opção "Add a README file" ou "Add .gitignore". Queremos um repositório vazio.
    *   Clique em `Create repository`.
7.  **Conecte seu repositório local ao GitHub:**
    Após criar o repositório no GitHub, ele mostrará algumas instruções. Copie as duas linhas que começam com `git remote add origin` e `git branch -M main` (ou `master`, dependendo da sua configuração padrão).
    ```bash
git remote add origin https://github.com/SEU_USUARIO/meu-primeiro-projeto.git
git branch -M main
    ```
    Substitua `SEU_USUARIO` pelo seu nome de usuário do GitHub.
8.  **Envie suas alterações para o GitHub:**
    ```bash
git push -u origin main
    ```
    O `-u origin main` define o branch `main` (ou `master`) do seu repositório remoto (`origin`) como o padrão para futuros `git push` e `git pull`.

### Opção B: Clonar um Repositório Existente do GitHub

Se você quer trabalhar em um projeto que já existe no GitHub (como este repositório de aprendizado):

1.  **Vá para a página do repositório no GitHub.**
2.  Clique no botão verde `Code` e copie a URL (geralmente HTTPS).
3.  **No seu terminal, use `git clone`:**
    ```bash
git clone https://github.com/webertmaximiano/local.dev.git
cd local.dev
    ```
    Isso baixa uma cópia completa do repositório para sua máquina.

## 3. O Fluxo de Trabalho Básico do Git

Depois de criar ou clonar um repositório, você seguirá um ciclo de trabalho:

1.  **Faça alterações nos seus arquivos.**
2.  **Verifique o status das alterações:**
    ```bash
git status
    ```
    Isso mostra quais arquivos foram modificados, adicionados ou excluídos.
3.  **Adicione as alterações ao staging area:**
    ```bash
git add .
    ```
    O `.` adiciona todos os arquivos modificados/novos. Você também pode adicionar arquivos específicos: `git add nome-do-arquivo.js`.
4.  **Faça um commit das alterações:**
    ```bash
git commit -m "Mensagem descritiva das minhas alterações"
    ```
    Seja claro e conciso na mensagem do commit. Ela deve explicar *o que* e *por que* você mudou.
5.  **Envie as alterações para o GitHub:**
    ```bash
git push
    ```
    Isso envia seus commits locais para o repositório remoto no GitHub.
6.  **Puxe as últimas alterações de outros colaboradores (se houver):**
    ```bash
git pull
    ```
    É uma boa prática fazer `git pull` antes de começar a trabalhar e antes de fazer um `git push` para garantir que você tem a versão mais recente do código.

## 4. Histórico de Commits

Para ver o histórico de todos os commits feitos no repositório:

```bash
git log
```

Use `q` para sair do `git log`.

## 5. Branches: Trabalhando em Paralelo

Branches permitem que você trabalhe em novas funcionalidades ou correções de bugs isoladamente, sem afetar o código principal (`main` ou `master`).

1.  **Crie um novo branch:**
    ```bash
git branch minha-nova-funcionalidade
    ```
2.  **Mude para o novo branch:**
    ```bash
git checkout minha-nova-funcionalidade
    ```
    Ou, para criar e mudar de uma vez:
    ```bash
git checkout -b minha-nova-funcionalidade
    ```
3.  **Trabalhe e faça commits normalmente neste branch.**
4.  **Volte para o branch principal:**
    ```bash
git checkout main
    ```
5.  **Mescle suas alterações (merge):**
    Quando sua funcionalidade estiver pronta no branch `minha-nova-funcionalidade`, você pode mesclá-la no `main`.
    ```bash
git merge minha-nova-funcionalidade
    ```
    Se houver conflitos (partes do código que foram alteradas em ambos os branches), o Git irá te avisar e você precisará resolvê-los manualmente.
6.  **Exclua o branch (opcional):**
    Após a mesclagem, você pode excluir o branch que não precisa mais:
    ```bash
git branch -d minha-nova-funcionalidade
    ```

## 6. Ignorando Arquivos (`.gitignore`)

Você não quer que o Git rastreie todos os arquivos (ex: arquivos de configuração sensíveis, dependências de pacotes, arquivos temporários). Para isso, crie um arquivo chamado `.gitignore` na raiz do seu projeto e liste os padrões de arquivos/pastas a serem ignorados.

**Exemplo de `.gitignore`:**

```
# Ignorar pastas de dependências
node_modules/
vendor/

# Ignorar arquivos de log
*.log

# Ignorar arquivos de configuração sensíveis
.env
config.local.js

# Ignorar arquivos temporários
*.tmp
*.bak
```

## Conclusão

Este guia cobriu os fundamentos do Git e GitHub. A prática leva à perfeição, então comece a usar essas ferramentas em seus projetos. Elas se tornarão uma segunda natureza para você e abrirão portas para a colaboração e o desenvolvimento profissional.
