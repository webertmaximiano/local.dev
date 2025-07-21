estamos configurando um ambiente de desenvolvimento e produnzindo tutoriais do passo a passo do caminho feliz, somente do que deu certo para orientar aos alunos.

já temos Ubuntu 24, Docker e Docker Desktop Instalados, habilitamos o Kubernetes via o docker desktop, instalamos o traefik e criamos o tutorial na pasta traefik, expomos a dashboard em traefik.local.dev,
configuramos prometheus e grafana prometheus.local.dev e grafana.local.dev, criamos uma dashboard no grafana para monitorar o traefik. Temos a pasta mysql e pgsql com deployments para os serviços.

Ao tentar subir a aplicação estouon.app.br no virtual dominio aqui no localhost estouon.dev front e api.estouon.dev eu não consegui guia a ia pra implementar e usar o nosso ambiente local que estamos desenvolvendo e ensinando no Guia de Aprendizado, preciso reconfigurar pois derrubei o traefik, o prometheu e o grafana, eles não estão funcionando pode testar com curl.

Depois de Recuperar o ambiente local  a 

Pode verificar o porque nosso sistema não consegue mapear um diretorio para um volume docker ou kubernetes permitindo agente altera um arquivo local e ele ser alterado no volume ou disco?

# cluster 
docker-desktop
kubeadm, 1 node, v1.32.2 - running

opção marcada 
Show system containers (advanced)
Show Kubernetes internal containers when using Docker comman

# traefik com kubernetes
Funcionando 

# Prometheus e Grafana com Kubernets
Funcionando

# padrão de configuração do traefik
usamos helm

# teste sempre
após realizar as configurações use o curl e verifica se consegue acessar a dashboard do traefik

# plano de ação
Se for uma IA para evitar loop e facilitar seu trabalho elabore um plano de ação e faça um checklist das tarefas e subtarefas adicione aqui seu checklist e mantenha atualizado
