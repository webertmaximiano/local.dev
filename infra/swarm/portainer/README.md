# Portainer no laboratório local

Portainer é um painel visual para inspecionar e administrar Docker Swarm. Neste laboratório ele é opcional: Traefik e as aplicações não dependem da interface para funcionar.

## Quando usar

Use Portainer durante as aulas e quando quiser visualizar rapidamente:

- stacks e serviços, e a relação entre eles;
- número de réplicas, estado das tarefas e nós do Swarm;
- logs de um serviço e detalhes de uma tarefa com falha;
- redes, volumes, imagens e Docker Secrets existentes;
- o efeito de escalar ou atualizar um serviço.

Para operações reproduzíveis, prefira registrar a configuração em arquivos versionados e usar `docker stack deploy` ou os alvos `make`. A interface ajuda a observar e praticar; mudanças feitas só pela interface podem divergir do manifesto e ser substituídas no próximo deploy. Compare o que você faz na interface com os comandos e arquivos para aprender as duas formas de operar.

## Ligar e desligar

Execute o comando na raiz do repositório; os arquivos da stack ficam nesta pasta, mas o Makefile central controla seu ciclo de vida:

```bash
make portainer-up
```

O Makefile confere o Traefik: se ele estiver saudável (`1/1`), mantém a stack atual; se estiver ausente ou sem réplica ativa, publica o Traefik antes do Portainer. Depois, publica Portainer Server e Agent.

Acesse `https://portainer.local.dev` e entre com o usuário administrador criado no primeiro acesso. Quando terminar de estudar ou precisar liberar recursos, desligue a stack:

```bash
make portainer-down
```

Isso remove os serviços Portainer e Agent, mas mantém o volume Docker externo `portainer_data`, que guarda os dados e a configuração do Portainer. O alvo não executa `docker volume rm` nem apaga os certificados. O Traefik continua funcionando. Para parar também o proxy quando não houver aplicações que dependam dele, use `make traefik-down`.

## Exercício recomendado

1. Execute `make status` e observe a stack `portainer` e os serviços `portainer_portainer` e `portainer_agent`.
2. No Portainer, abra **Services** e compare o modo global do Agent com a réplica do Server.
3. Abra um serviço, examine suas tarefas e logs; compare com `docker service ps` e `docker service logs`.
4. Escale um serviço de exemplo e observe a mudança nas tarefas. Depois restaure a quantidade de réplicas declarada no manifesto.
5. Execute `make portainer-down`, confirme que o proxy e as demais stacks continuam ativos e ligue Portainer novamente quando precisar.

Um Swarm de nó único permite praticar o fluxo de orquestração, mas todas as réplicas usam os recursos do mesmo computador. Ligar Portainer consome recursos adicionais; mantenha-o desligado quando não estiver usando, especialmente em máquinas com pouca memória.

## Versão e atualização

A stack fixa Server e Agent na mesma versão estável (`2.45.3` neste laboratório). Antes de atualizar, confira o [release oficial do Portainer](https://github.com/portainer/portainer/releases), altere as duas imagens juntas em `stack.yml` e aplique com `make portainer-up`. O volume persistente mantém os dados durante a atualização.

## Segurança

O Agent monta o socket Docker para administrar o Swarm. Quem controla o Portainer pode ter controle elevado sobre o Docker Engine e o host; trate o acesso como administrativo.

- Use uma senha administrativa forte e individual.
- Não exponha Portainer ou o Agent à Internet. Neste laboratório, acesse Portainer pelo Traefik local.
- Não compartilhe a conta de administrador com alunos; cada ambiente de produção deve ter identidade e permissões próprias.
- O Makefile consulta `docker info` para montar o diretório de volumes do Engine, sem presumir `/var/lib/docker`. Em Swarm com vários nós, esse caminho deve existir em todos os nós onde o Agent rodar.
