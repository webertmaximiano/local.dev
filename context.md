estamos configurando um ambiente de desenvolvimento e produnzindo tutoriais do passo a passo do caminho feliz, somente do que deu certo para orientar aos alunos.

já temos Ubuntu 24, Docker e Docker Desktop Instalados, habilitamos o Kubernetes via o docker desktop, instalamos o traefik e criamos o tutorial na pasta traefik, expomos a dashboard em traefik.local.dev,
configuramos prometheus e grafana prometheus.local.dev e grafana.local.dev, criamos uma dashboard no grafana para monitorar o traefik. Temos a pasta mysql e pgsql com deployments para os serviços, ensinamos subir uma aplicação para desenvolvimento local o hello-world-app.

Aguardando novas aulas e treinamentos para nossos alunos.

# cluster 
docker-desktop
kubeadm, 1 node, v1.32.2 - running

opção marcada 
Show system containers (advanced)
Show Kubernetes internal containers when using Docker comman

# Traefik, Prometheus e Grafana com kubernetes
Funcionando 

# padrão de configuração do traefik, do monitoring (Prometheus e Grafana)
usamos helm

# teste sempre
após realizar as configurações use o curl e verifica se consegue acessar a dashboard do traefik

# plano de ação
Se para evitar loop e facilitar seu trabalho elabore um plano de ação e faça um checklist das tarefas e subtarefas adicione aqui seu checklist e mantenha atualizado
