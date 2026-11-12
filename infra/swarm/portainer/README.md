# Portainer opcional

A stack fixa Server e Agent na mesma versão estável (`2.45.3` no momento desta atualização); atualize ambos juntos após conferir o release oficial.

Portainer fornece uma interface gráfica para aprender e administrar Swarm. Ele é uma stack separada e pode ficar desligado. Ao iniciar, o Makefile verifica o Traefik e só o publica se estiver ausente ou sem réplica saudável; assim um Traefik já saudável não é reaplicado:

```bash
make portainer-up
make portainer-down
```

O primeiro acesso é `https://portainer.local.dev`; crie o usuário administrador na tela inicial. O Portainer usa a rede `web-local` e o Traefik central.

O Agent é global e precisa montar o diretório de volumes do Docker Engine. O Makefile consulta `docker info` e passa o valor como `DOCKER_ROOT_DIR`; assim não presume `/var/lib/docker`. Em um Swarm de vários nós, o caminho precisa existir nos nós onde o Agent executará.

O Agent monta o socket Docker para administrar o Swarm; trate esse acesso como privilegiado. Não exponha a stack à Internet sem configuração de segurança apropriada.
