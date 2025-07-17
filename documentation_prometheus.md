Visão geral
O que é Prometheus?
O Prometheus é um kit de ferramentas de monitoramento e alerta de sistemas de código aberto, originalmente desenvolvido no SoundCloud . Desde sua criação em 2012, muitas empresas e organizações adotaram o Prometheus, e o projeto conta com uma comunidade de desenvolvedores e usuários bastante ativa . Atualmente, é um projeto independente de código aberto, mantido independentemente de qualquer empresa. Para enfatizar isso e esclarecer a estrutura de governança do projeto, o Prometheus se juntou à Cloud Native Computing Foundation em 2016 como o segundo projeto hospedado, depois do Kubernetes .

O Prometheus coleta e armazena suas métricas como dados de séries temporais, ou seja, as informações das métricas são armazenadas com o registro de data e hora em que foram registradas, juntamente com pares de chave-valor opcionais chamados rótulos.

Para visões gerais mais elaboradas do Prometheus, consulte os recursos vinculados na seção de mídia .

Características
As principais características do Prometheus são:

um modelo de dados multidimensional com dados de séries temporais identificados pelo nome da métrica e pares chave/valor
PromQL, uma linguagem de consulta flexível para alavancar essa dimensionalidade
nenhuma dependência de armazenamento distribuído; os nós de servidor único são autônomos
a coleta de séries temporais ocorre por meio de um modelo pull sobre HTTP
o envio de séries temporais é suportado por meio de um gateway intermediário
os alvos são descobertos por meio da descoberta de serviço ou configuração estática
vários modos de suporte para gráficos e painéis
O que são métricas?
Métricas são medições numéricas em termos leigos. O termo séries temporais refere-se ao registro de mudanças ao longo do tempo. O que os usuários desejam medir difere de aplicativo para aplicativo. Para um servidor web, pode ser o tempo de solicitação; para um banco de dados, pode ser o número de conexões ativas ou consultas ativas, e assim por diante.

As métricas desempenham um papel importante na compreensão de por que seu aplicativo está funcionando de determinada maneira. Vamos supor que você esteja executando um aplicativo web e perceba que ele está lento. Para entender o que está acontecendo com seu aplicativo, você precisará de algumas informações. Por exemplo, quando o número de solicitações é alto, o aplicativo pode ficar lento. Se você tiver a métrica de contagem de solicitações, poderá determinar a causa e aumentar o número de servidores para lidar com a carga.

Componentes
O ecossistema Prometheus consiste em vários componentes, muitos dos quais são opcionais:

o servidor principal do Prometheus que coleta e armazena dados de séries temporais
bibliotecas de clientes para instrumentação de código de aplicativo
um gateway push para dar suporte a empregos de curta duração
exportadores de propósito específico para serviços como HAProxy, StatsD, Graphite, etc.
um gerenciador de alertas para lidar com alertas
várias ferramentas de suporte
A maioria dos componentes do Prometheus são escritos em Go , o que os torna fáceis de construir e implantar como binários estáticos.

Arquitetura
Este diagrama ilustra a arquitetura do Prometheus e alguns dos componentes do seu ecossistema:

Arquitetura Prometeu

O Prometheus coleta métricas de trabalhos instrumentados, seja diretamente ou por meio de um gateway de push intermediário para trabalhos de curta duração. Ele armazena todas as amostras coletadas localmente e executa regras sobre esses dados para agregar e registrar novas séries temporais a partir de dados existentes ou gerar alertas. O Grafana ou outros consumidores de API podem ser usados para visualizar os dados coletados.

Quando é adequado?
O Prometheus funciona bem para registrar qualquer série temporal puramente numérica. Ele se adapta tanto ao monitoramento centrado em máquina quanto ao monitoramento de arquiteturas orientadas a serviços altamente dinâmicas. Em um mundo de microsserviços, seu suporte à coleta e consulta de dados multidimensionais é um ponto forte.

O Prometheus foi projetado para ser confiável, sendo o sistema ao qual você recorre durante uma interrupção para permitir o diagnóstico rápido de problemas. Cada servidor Prometheus é independente, não dependendo de armazenamento em rede ou outros serviços remotos. Você pode contar com ele quando outras partes da sua infraestrutura estiverem com problemas, sem precisar configurar uma infraestrutura extensa para usá-lo.

Quando não serve?
O Prometheus preza pela confiabilidade. Você sempre pode visualizar as estatísticas disponíveis sobre o seu sistema, mesmo em condições de falha. Se você precisa de 100% de precisão, como para faturamento por solicitação, o Prometheus não é uma boa opção, pois os dados coletados provavelmente não serão detalhados e completos o suficiente. Nesse caso, seria melhor usar outro sistema para coletar e analisar os dados para faturamento, e o Prometheus para o restante do monitoramento.



Primeiros passos com Prometheus
Bem-vindo ao Prometheus! O Prometheus é uma plataforma de monitoramento que coleta métricas de alvos monitorados por meio da coleta de métricas de endpoints HTTP nesses alvos. Este guia mostrará como instalar, configurar e monitorar nosso primeiro recurso com o Prometheus. Você baixará, instalará e executará o Prometheus. Você também baixará e instalará um exportador, ferramentas que expõem dados de séries temporais em hosts e serviços. Nosso primeiro exportador será o próprio Prometheus, que fornece uma ampla variedade de métricas em nível de host sobre uso de memória, coleta de lixo e muito mais.

Baixando o Prometheus
Baixe a versão mais recente do Prometheus para sua plataforma e extraia-a:

tar xvfz prometheus-*.tar.gz
cd prometheus-*
O servidor Prometheus é um único binário chamado prometheus(ou prometheus.exeno Microsoft Windows). Podemos executar o binário e ver ajuda sobre suas opções passando o --helpsinalizador.

./prometheus --help
usage: prometheus [<flags>]

The Prometheus monitoring server

. . .
Antes de iniciar o Prometheus, vamos configurá-lo.

Configurando o Prometheus
A configuração do Prometheus é YAML . O download do Prometheus vem com uma configuração de exemplo em um arquivo chamado , prometheus.ymlque é um bom ponto de partida.

Retiramos a maioria dos comentários no arquivo de exemplo para torná-lo mais sucinto (comentários são as linhas prefixadas com #).

global:
  scrape_interval:     15s
  evaluation_interval: 15s

rule_files:
  # - "first.rules"
  # - "second.rules"

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
Há três blocos de configuração no arquivo de configuração de exemplo: global, rule_filese scrape_configs.

O globalbloco controla a configuração global do servidor Prometheus. Temos duas opções presentes. A primeira, scrape_interval, controla a frequência com que o Prometheus realizará a coleta de dados em alvos. Você pode substituir essa configuração para alvos individuais. Neste caso, a configuração global é coletar dados a cada 15 segundos. A evaluation_intervalopção controla a frequência com que o Prometheus avaliará as regras. O Prometheus usa regras para criar novas séries temporais e gerar alertas.

O rule_filesbloco especifica a localização de quaisquer regras que queremos que o servidor Prometheus carregue. Por enquanto, não temos regras.

O último bloco, scrape_configs, controla quais recursos o Prometheus monitora. Como o Prometheus também expõe dados sobre si mesmo como um endpoint HTTP, ele pode extrair e monitorar sua própria integridade. Na configuração padrão, há uma única tarefa, chamada prometheus, que extrai os dados de série temporal expostos pelo servidor Prometheus. A tarefa contém um único destino estaticamente configurado, a localhostporta 9090. O Prometheus espera que as métricas estejam disponíveis em destinos em um caminho de /metrics. Portanto, esta tarefa padrão extrai dados por meio da URL: http://localhost:9090/metrics .

Os dados da série temporal retornados detalharão o estado e o desempenho do servidor Prometheus.

Para uma especificação completa das opções de configuração, consulte a documentação de configuração .

Iniciando Prometheus
Para iniciar o Prometheus com nosso arquivo de configuração recém-criado, vá para o diretório que contém o binário do Prometheus e execute:

./prometheus --config.file=prometheus.yml
O Prometheus deve iniciar. Você também deve conseguir navegar até uma página de status sobre ele em http://localhost:9090 . Aguarde cerca de 30 segundos para que ele colete dados sobre si mesmo a partir do seu próprio endpoint de métricas HTTP.

Você também pode verificar se o Prometheus está fornecendo métricas sobre si mesmo navegando até seu próprio ponto de extremidade de métricas: http://localhost:9090/metrics .

Usando o navegador de expressões
Vamos tentar analisar alguns dados que o Prometheus coletou sobre si mesmo. Para usar o navegador de expressões integrado do Prometheus, acesse http://localhost:9090/graph e escolha a visualização "Tabela" na aba "Gráfico".

Como você pode perceber em http://localhost:9090/metrics , uma métrica que o Prometheus exporta sobre si mesmo é chamada de promhttp_metric_handler_requests_total(número total de /metricsrequisições atendidas pelo servidor Prometheus). Vá em frente e insira isso no console de expressões:

promhttp_metric_handler_requests_total
Isso deve retornar várias séries temporais diferentes (junto com o valor mais recente registrado para cada uma), todas com o nome da métrica promhttp_metric_handler_requests_total, mas com rótulos diferentes. Esses rótulos designam diferentes status de solicitações.

Se estivéssemos interessados apenas em solicitações que resultassem em código HTTP 200, poderíamos usar esta consulta para recuperar essas informações:

promhttp_metric_handler_requests_total{code="200"}
Para contar o número de séries temporais retornadas, você pode escrever:

count(promhttp_metric_handler_requests_total)
Para mais informações sobre a linguagem de expressão, consulte a documentação da linguagem de expressão .

Usando a interface gráfica
Para representar graficamente expressões, navegue até http://localhost:9090/graph e use a aba "Gráfico".

Por exemplo, insira a seguinte expressão para representar graficamente a taxa de solicitações HTTP por segundo que retornam o código de status 200 ocorrendo no Prometheus autoextraído:

rate(promhttp_metric_handler_requests_total{code="200"}[1m])
Você pode experimentar os parâmetros de intervalo do gráfico e outras configurações.

Monitoramento de outros alvos
Coletar métricas apenas do Prometheus não é uma boa representação dos recursos do Prometheus. Para ter uma ideia melhor do que o Prometheus pode fazer, recomendamos explorar a documentação sobre outros exportadores. O guia "Monitorando métricas de host Linux ou macOS usando um exportador de nós" é um bom ponto de partida.

Resumo
Neste guia, você instalou o Prometheus, configurou uma instância do Prometheus para monitorar recursos e aprendeu alguns conceitos básicos sobre como trabalhar com dados de séries temporais no navegador de expressões do Prometheus. Para continuar aprendendo sobre o Prometheus, confira a Visão Geral para obter algumas ideias sobre o que explorar em seguida.


Documentos de design
Consulte o repositório github.com/prometheus/proposals para ver todas as propostas anteriores e atuais para o ecossistema Prometheus.

Se você estiver interessado em criar uma nova proposta, leia nosso processo de proposta .

Declarações de problemas e documentos exploratórios
Às vezes, olhamos ainda mais a fundo para futuros potenciais. Os documentos desta seção são em grande parte exploratórios. Devem ser considerados como elementos que informam nossas reflexões coletivas, não como algo concreto ou específico.

Documento	Data inicial
Prometheus não está completo	2020-05
Reflexões sobre carimbos de data/hora e durações em PromQL	2020-10
Prometheus, OpenMetrics e OTLP	2021-03
Histogramas esparsos do Prometheus e PromQL	2021-10
Citando nomes de Prometeu	2023-01



Mídia
Há um subreddit que reúne todos os recursos relacionados ao Prometheus na internet.

A seleção de recursos a seguir é particularmente útil para começar a usar o Prometheus. O Awesome Prometheus contém uma lista de recursos mais abrangente, mantida pela comunidade.

Blogs
Este site tem seu próprio blog .
Postagem do blog do SoundCloud anunciando Prometheus – uma visão geral mais elaborada do que a fornecida neste site.
Postagens relacionadas ao Prometheus no blog Robust Perception .
Tutoriais
Instruções e código de exemplo para um workshop do Prometheus .
Como instalar o Prometheus usando o Docker no Ubuntu 14.04 .
Podcasts e entrevistas
Prometheus no FLOSS Weekly 357 - Julius Volz no programa FLOSS Weekly TWiT.tv.
Prometheus e monitoramento de serviço - Julius Volz no podcast Changelog .
Palestras gravadas
Prometheus: Um Sistema de Monitoramento de Próxima Geração – Julius Volz e Björn Rabenstein na SREcon15 Europe, Dublin.
Prometheus: Um sistema de monitoramento de última geração - Brian Brazil na FOSDEM 2016 ( slides ).
O que seu aplicativo está fazendo agora? – Matthias Gruter, Transmode, no DevOps Stockholm Meetup.
Workshop Prometheus – Jamie Wilkinson no Monitorama PDX 2015 ( slides ).
Monitoramento do Hadoop com Prometheus – Brian Brazil no Hadoop User Group Ireland ( slides ).
Em alemão: Monitoramento com Prometheus – Michael Stapelberg na Easterhegg 2016 .
Em alemão: Prometheus in der Praxis – Jonas Große Sundrup no MRMCD 2016


Começando
Este guia é um tutorial no estilo "Olá, Mundo" que mostra como instalar, configurar e usar uma instância simples do Prometheus. Você baixará e executará o Prometheus localmente, configurará a extração de dados de si mesmo e de um aplicativo de exemplo e, em seguida, trabalhará com consultas, regras e gráficos para usar os dados de séries temporais coletados.

Baixando e executando o Prometheus
Baixe a versão mais recente do Prometheus para sua plataforma, extraia e execute:

tar xvfz prometheus-*.tar.gz
cd prometheus-*
Antes de iniciar o Prometheus, vamos configurá-lo.

Configurando o Prometheus para monitorar a si mesmo
O Prometheus coleta métricas de alvos por meio da coleta de métricas de endpoints HTTP. Como o Prometheus expõe dados sobre si mesmo da mesma maneira, ele também pode coletar e monitorar sua própria integridade.

Embora um servidor Prometheus que coleta apenas dados sobre si mesmo não seja muito útil, é um bom exemplo inicial. Salve a seguinte configuração básica do Prometheus como um arquivo chamado prometheus.yml:

global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
Para uma especificação completa das opções de configuração, consulte a documentação de configuração .

Iniciando Prometheus
Para iniciar o Prometheus com o arquivo de configuração recém-criado, vá para o diretório que contém o binário do Prometheus e execute:

# Start Prometheus.
# By default, Prometheus stores its database in ./data (flag --storage.tsdb.path).
./prometheus --config.file=prometheus.yml
O Prometheus deve iniciar. Você também deve conseguir navegar até uma página de status sobre ele em localhost:9090 . Aguarde alguns segundos para que ele colete dados sobre si mesmo a partir do seu próprio endpoint de métricas HTTP.

Você também pode verificar se o Prometheus está fornecendo métricas sobre si mesmo navegando até seu ponto de extremidade de métricas: localhost:9090/metrics

Usando o navegador de expressões
Vamos explorar os dados que o Prometheus coletou sobre si mesmo. Para usar o navegador de expressões integrado do Prometheus, acesse http://localhost:9090/graph e escolha a visualização "Tabela" na aba "Gráfico".

Como você pode perceber em localhost:9090/metrics , uma métrica que o Prometheus exporta sobre si mesmo é nomeada prometheus_target_interval_length_seconds(o tempo real entre as coletas de dados de destino). Insira o seguinte no console de expressões e clique em "Executar":

prometheus_target_interval_length_seconds
Isso deve retornar uma série de séries temporais diferentes (junto com o valor mais recente registrado para cada uma), cada uma com o nome da métrica prometheus_target_interval_length_seconds, mas com rótulos diferentes. Esses rótulos designam diferentes percentis de latência e intervalos de grupos-alvo.

Se estivermos interessados apenas nas latências do 99º percentil, poderíamos usar esta consulta:

prometheus_target_interval_length_seconds{quantile="0.99"}
Para contar o número de séries temporais retornadas, você pode escrever:

count(prometheus_target_interval_length_seconds)
Para mais informações sobre a linguagem de expressão, consulte a documentação da linguagem de expressão .

Usando a interface gráfica
Para representar graficamente expressões, navegue até http://localhost:9090/graph e use a aba "Gráfico".

Por exemplo, insira a seguinte expressão para representar graficamente a taxa por segundo de blocos criados no Prometheus autoraspado:

rate(prometheus_tsdb_head_chunks_created_total[1m])
Experimente os parâmetros de intervalo do gráfico e outras configurações.

Iniciando alguns alvos de amostra
Vamos adicionar alvos adicionais para o Prometheus explorar.

O Node Exporter é usado como um alvo de exemplo. Para mais informações sobre como usá-lo, consulte estas instruções.

tar -xzvf node_exporter-*.*.tar.gz
cd node_exporter-*.*

# Start 3 example targets in separate terminals:
./node_exporter --web.listen-address 127.0.0.1:8080
./node_exporter --web.listen-address 127.0.0.1:8081
./node_exporter --web.listen-address 127.0.0.1:8082
Agora você deve ter alvos de exemplo escutando em http://localhost:8080/metrics , http://localhost:8081/metrics e http://localhost:8082/metrics .

Configurar o Prometheus para monitorar os alvos de amostra
Agora, configuraremos o Prometheus para extrair dados desses novos alvos. Vamos agrupar os três endpoints em uma tarefa chamada node. Imaginaremos que os dois primeiros endpoints são alvos de produção, enquanto o terceiro representa uma instância canário. Para modelar isso no Prometheus, podemos adicionar vários grupos de endpoints a uma única tarefa, adicionando rótulos extras a cada grupo de alvos. Neste exemplo, adicionaremos o group="production"rótulo ao primeiro grupo de alvos e, ao mesmo tempo, adicionaremos group="canary"ao segundo.

Para fazer isso, adicione a seguinte definição de tarefa à scrape_configs seção prometheus.ymle reinicie sua instância do Prometheus:

scrape_configs:
  - job_name:       'node'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:8080', 'localhost:8081']
        labels:
          group: 'production'

      - targets: ['localhost:8082']
        labels:
          group: 'canary'
Acesse o navegador de expressões e verifique se o Prometheus agora tem informações sobre séries temporais que esses pontos de extremidade de exemplo expõem, como node_cpu_seconds_total.

Configurar regras para agregar dados coletados em novas séries temporais
Embora não seja um problema em nosso exemplo, consultas que agregam milhares de séries temporais podem ficar lentas quando computadas ad hoc. Para tornar isso mais eficiente, o Prometheus pode pré-gravar expressões em novas séries temporais persistentes por meio de regras de gravação configuradas . Digamos que estamos interessados em registrar a taxa de tempo de CPU ( node_cpu_seconds_total) por segundo, calculada em média sobre todas as CPUs por instância (mas preservando as dimensões job, instancee mode ), medida em uma janela de 5 minutos. Poderíamos escrever isso como:

avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
Tente representar graficamente esta expressão.

Para registrar a série temporal resultante desta expressão em uma nova métrica chamada job_instance_mode:node_cpu_seconds:avg_rate5m, crie um arquivo com a seguinte regra de gravação e salve-o como prometheus.rules.yml:

groups:
- name: cpu-node
  rules:
  - record: job_instance_mode:node_cpu_seconds:avg_rate5m
    expr: avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
Para que o Prometheus aceite essa nova regra, adicione uma rule_filesinstrução no seu arquivo prometheus.yml. A configuração agora deve ficar assim:

global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.
  evaluation_interval: 15s # Evaluate rules every 15 seconds.

  # Attach these extra labels to all timeseries collected by this Prometheus instance.
  external_labels:
    monitor: 'codelab-monitor'

rule_files:
  - 'prometheus.rules.yml'

scrape_configs:
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']

  - job_name:       'node'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:8080', 'localhost:8081']
        labels:
          group: 'production'

      - targets: ['localhost:8082']
        labels:
          group: 'canary'
Reinicie o Prometheus com a nova configuração e verifique se uma nova série temporal com o nome da métrica job_instance_mode:node_cpu_seconds:avg_rate5m agora está disponível consultando-a no navegador de expressões ou criando um gráfico.

Recarregando a configuração
Conforme mencionado na documentação de configuração, uma instância do Prometheus pode ter sua configuração recarregada sem reiniciar o processo usando o SIGHUPsinal. Se você estiver executando no Linux, isso pode ser feito usando kill -s SIGHUP <PID>, substituindo <PID>pelo ID do seu processo do Prometheus.

Desligando sua instância com elegância.
Embora o Prometheus possua mecanismos de recuperação em caso de falha abrupta do processo, recomenda-se o uso de sinais ou interrupções para um desligamento limpo de uma instância do Prometheus. No Linux, isso pode ser feito enviando os sinais SIGTERMou SIGINTpara o processo do Prometheus. Por exemplo, você pode usar kill -s <SIGNAL> <PID>, substituindo <SIGNAL>pelo nome do sinal e <PID>pelo ID do processo do Prometheus. Como alternativa, você pode pressionar o caractere de interrupção no terminal de controle, que por padrão é ^C(Control-C).

Instalação
Usando binários pré-compilados
Fornecemos binários pré-compilados para a maioria dos componentes oficiais do Prometheus. Confira a seção de downloads para obter uma lista de todas as versões disponíveis.

Da fonte
Para construir componentes do Prometheus a partir do código-fonte, consulte os Makefiledestinos no respectivo repositório.

Usando o Docker
Todos os serviços do Prometheus estão disponíveis como imagens do Docker no Quay.io ou no Docker Hub .

Executar o Prometheus no Docker é tão simples quanto docker run -p 9090:9090 prom/prometheus... Isso inicia o Prometheus com uma configuração de exemplo e a expõe na porta 9090.

A imagem do Prometheus usa um volume para armazenar as métricas reais. Para implantações de produção, é altamente recomendável usar um volume nomeado para facilitar o gerenciamento dos dados nas atualizações do Prometheus.

Configurando parâmetros de linha de comando
A imagem do Docker é iniciada com uma série de parâmetros de linha de comando padrão, que podem ser encontrados no Dockerfile (ajuste o link para corresponder à versão em uso).

Se quiser adicionar parâmetros extras de linha de comando ao docker runcomando, você precisará adicioná-los novamente, pois eles serão substituídos.

Volumes e encadernação
Existem várias opções para você criar sua própria configuração. Aqui estão dois exemplos.

Monte seu Bind prometheus.ymla partir do host executando:

docker run \
    -p 9090:9090 \
    -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus
Ou monte o diretório que contém prometheus.ymlonto /etc/prometheusexecutando:

docker run \
    -p 9090:9090 \
    -v /path/to/config:/etc/prometheus \
    prom/prometheus
Salve seus dados do Prometheus
Os dados do Prometheus são armazenados em /prometheusum diretório dentro do contêiner, portanto, os dados são apagados sempre que o contêiner é reiniciado. Para salvar seus dados, você precisa configurar o armazenamento persistente (ou montagens de vinculação) para o seu contêiner.

Execute o contêiner Prometheus com armazenamento persistente:

# Create persistent volume for your data
docker volume create prometheus-data
# Start Prometheus container
docker run \
    -p 9090:9090 \
    -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v prometheus-data:/prometheus \
    prom/prometheus
Imagem personalizada
Para evitar o gerenciamento de um arquivo no host e a montagem vinculada, a configuração pode ser incorporada à imagem. Isso funciona bem se a configuração em si for estática e a mesma em todos os ambientes.

Para isso, crie um novo diretório com uma configuração do Prometheus como Dockerfileesta:

FROM prom/prometheus
ADD prometheus.yml /etc/prometheus/
Agora crie e execute:

docker build -t my-prometheus .
docker run -p 9090:9090 my-prometheus
Uma opção mais avançada é renderizar a configuração dinamicamente na inicialização com algumas ferramentas ou até mesmo ter um daemon atualizando-a periodicamente.

Usando sistemas de gerenciamento de configuração
Se você preferir usar sistemas de gerenciamento de configuração, talvez se interesse pelas seguintes contribuições de terceiros:

Ansible
comunidade-prometheus/ansible
Chefe de cozinha
rayrod2030/chef-prometheus
Fantoche
fantoche/prometeu
Pilha de Sal
fórmulas saltstack/fórmula prometheus

Configuration
Prometheus is configured via command-line flags and a configuration file. While the command-line flags configure immutable system parameters (such as storage locations, amount of data to keep on disk and in memory, etc.), the configuration file defines everything related to scraping jobs and their instances, as well as which rule files to load.

To view all available command-line flags, run ./prometheus -h.

Prometheus can reload its configuration at runtime. If the new configuration is not well-formed, the changes will not be applied. A configuration reload is triggered by sending a SIGHUP to the Prometheus process or sending a HTTP POST request to the /-/reload endpoint (when the --web.enable-lifecycle flag is enabled). This will also reload any configured rule files.

Configuration file
To specify which configuration file to load, use the --config.file flag.

The file is written in YAML format, defined by the scheme described below. Brackets indicate that a parameter is optional. For non-list parameters the value is set to the specified default.

Generic placeholders are defined as follows:

<boolean>: a boolean that can take the values true or false
<duration>: a duration matching the regular expression ((([0-9]+)y)?(([0-9]+)w)?(([0-9]+)d)?(([0-9]+)h)?(([0-9]+)m)?(([0-9]+)s)?(([0-9]+)ms)?|0), e.g. 1d, 1h30m, 5m, 10s
<filename>: a valid path in the current working directory
<float>: a floating-point number
<host>: a valid string consisting of a hostname or IP followed by an optional port number
<int>: an integer value
<labelname>: a string matching the regular expression [a-zA-Z_][a-zA-Z0-9_]*. Any other unsupported character in the source label should be converted to an underscore. For example, the label app.kubernetes.io/name should be written as app_kubernetes_io_name.
<labelvalue>: a string of unicode characters
<path>: a valid URL path
<scheme>: a string that can take the values http or https
<secret>: a regular string that is a secret, such as a password
<string>: a regular string
<size>: a size in bytes, e.g. 512MB. A unit is required. Supported units: B, KB, MB, GB, TB, PB, EB.
<tmpl_string>: a string which is template-expanded before usage
The other placeholders are specified separately.

A valid example file can be found here.

The global configuration specifies parameters that are valid in all other configuration contexts. They also serve as defaults for other configuration sections.

global:
  # How frequently to scrape targets by default.
  [ scrape_interval: <duration> | default = 1m ]

  # How long until a scrape request times out.
  # It cannot be greater than the scrape interval.
  [ scrape_timeout: <duration> | default = 10s ]

  # The protocols to negotiate during a scrape with the client.
  # Supported values (case sensitive): PrometheusProto, OpenMetricsText0.0.1,
  # OpenMetricsText1.0.0, PrometheusText0.0.4.
  # The default value changes to [ PrometheusProto, OpenMetricsText1.0.0, OpenMetricsText0.0.1, PrometheusText0.0.4 ]
  # when native_histogram feature flag is set.
  [ scrape_protocols: [<string>, ...] | default = [ OpenMetricsText1.0.0, OpenMetricsText0.0.1, PrometheusText0.0.4 ] ]

  # How frequently to evaluate rules.
  [ evaluation_interval: <duration> | default = 1m ]

  # Offset the rule evaluation timestamp of this particular group by the
  # specified duration into the past to ensure the underlying metrics have
  # been received. Metric availability delays are more likely to occur when
  # Prometheus is running as a remote write target, but can also occur when
  # there's anomalies with scraping.
  [ rule_query_offset: <duration> | default = 0s ]

  # The labels to add to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  # Environment variable references `${var}` or `$var` are replaced according
  # to the values of the current environment variables.
  # References to undefined variables are replaced by the empty string.
  # The `$` character can be escaped by using `$$`.
  external_labels:
    [ <labelname>: <labelvalue> ... ]

  # File to which PromQL queries are logged.
  # Reloading the configuration will reopen the file.
  [ query_log_file: <string> ]

  # File to which scrape failures are logged.
  # Reloading the configuration will reopen the file.
  [ scrape_failure_log_file: <string> ]

  # An uncompressed response body larger than this many bytes will cause the
  # scrape to fail. 0 means no limit. Example: 100MB.
  # This is an experimental feature, this behaviour could
  # change or be removed in the future.
  [ body_size_limit: <size> | default = 0 ]

  # Per-scrape limit on the number of scraped samples that will be accepted.
  # If more than this number of samples are present after metric relabeling
  # the entire scrape will be treated as failed. 0 means no limit.
  [ sample_limit: <int> | default = 0 ]

  # Limit on the number of labels that will be accepted per sample. If more
  # than this number of labels are present on any sample post metric-relabeling,
  # the entire scrape will be treated as failed. 0 means no limit.
  [ label_limit: <int> | default = 0 ]

  # Limit on the length (in bytes) of each individual label name. If any label
  # name in a scrape is longer than this number post metric-relabeling, the
  # entire scrape will be treated as failed. Note that label names are UTF-8
  # encoded, and characters can take up to 4 bytes. 0 means no limit.
  [ label_name_length_limit: <int> | default = 0 ]

  # Limit on the length (in bytes) of each individual label value. If any label
  # value in a scrape is longer than this number post metric-relabeling, the
  # entire scrape will be treated as failed. Note that label values are UTF-8
  # encoded, and characters can take up to 4 bytes. 0 means no limit.
  [ label_value_length_limit: <int> | default = 0 ]

  # Limit per scrape config on number of unique targets that will be
  # accepted. If more than this number of targets are present after target
  # relabeling, Prometheus will mark the targets as failed without scraping them.
  # 0 means no limit. This is an experimental feature, this behaviour could
  # change in the future.
  [ target_limit: <int> | default = 0 ]

  # Limit per scrape config on the number of targets dropped by relabeling
  # that will be kept in memory. 0 means no limit.
  [ keep_dropped_targets: <int> | default = 0 ]

  # Specifies the validation scheme for metric and label names. Either blank or
  # "utf8" for full UTF-8 support, or "legacy" for letters, numbers, colons,
  # and underscores.
  [ metric_name_validation_scheme: <string> | default "utf8" ]

  # Specifies whether to convert all scraped classic histograms into native
  # histograms with custom buckets.
  [ convert_classic_histograms_to_nhcb: <bool> | default = false]

  # Specifies whether to scrape a classic histogram, even if it is also exposed as a native
  # histogram (has no effect without --enable-feature=native-histograms).
  [ always_scrape_classic_histograms: <boolean> | default = false ]


runtime:
  # Configure the Go garbage collector GOGC parameter
  # See: https://tip.golang.org/doc/gc-guide#GOGC
  # Lowering this number increases CPU usage.
  [ gogc: <int> | default = 75 ]

# Rule files specifies a list of globs. Rules and alerts are read from
# all matching files.
rule_files:
  [ - <filepath_glob> ... ]

# Scrape config files specifies a list of globs. Scrape configs are read from
# all matching files and appended to the list of scrape configs.
scrape_config_files:
  [ - <filepath_glob> ... ]

# A list of scrape configurations.
scrape_configs:
  [ - <scrape_config> ... ]

# Alerting specifies settings related to the Alertmanager.
alerting:
  alert_relabel_configs:
    [ - <relabel_config> ... ]
  alertmanagers:
    [ - <alertmanager_config> ... ]

# Settings related to the remote write feature.
remote_write:
  [ - <remote_write> ... ]

# Settings related to the OTLP receiver feature.
# See https://prometheus.io/docs/guides/opentelemetry/ for best practices.
otlp:
  # Promote specific list of resource attributes to labels.
  # It cannot be configured simultaneously with 'promote_all_resource_attributes: true'.
  [ promote_resource_attributes: [<string>, ...] | default = [ ] ]
  # Promoting all resource attributes to labels, except for the ones configured with 'ignore_resource_attributes'.
  # Be aware that changes in attributes received by the OTLP endpoint may result in time series churn and lead to high memory usage by the Prometheus server.
  # It cannot be set to 'true' simultaneously with 'promote_resource_attributes'.
  [ promote_all_resource_attributes: <boolean> | default = false ]
  # Which resource attributes to ignore, can only be set when 'promote_all_resource_attributes' is true.
  [ ignore_resource_attributes: [<string>, ...] | default = [] ]
  # Configures translation of OTLP metrics when received through the OTLP metrics
  # endpoint. Available values:
  # - "UnderscoreEscapingWithSuffixes" refers to commonly agreed normalization used
  #   by OpenTelemetry in https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/pkg/translator/prometheus
  # - "NoUTF8EscapingWithSuffixes" is a mode that relies on UTF-8 support in Prometheus.
  #   It preserves all special characters like dots, but still adds required metric name suffixes
  #   for units and _total, as UnderscoreEscapingWithSuffixes does.
  # - (EXPERIMENTAL) "NoTranslation" is a mode that relies on UTF-8 support in Prometheus.
  #   It preserves all special character like dots and won't append special suffixes for metric
  #   unit and type.
  #
  #   WARNING: The "NoTranslation" setting has significant known risks and limitations (see https://prometheus.io/docs/practices/naming/
  #   for details):
  #       * Impaired UX when using PromQL in plain YAML (e.g. alerts, rules, dashboard, autoscaling configuration).
  #       * Series collisions which in the best case may result in OOO errors, in the worst case a silently malformed
  #         time series. For instance, you may end up in situation of ingesting `foo.bar` series with unit
  #         `seconds` and a separate series `foo.bar` with unit `milliseconds`.
  [ translation_strategy: <string> | default = "UnderscoreEscapingWithSuffixes" ]
  # Enables adding "service.name", "service.namespace" and "service.instance.id"
  # resource attributes to the "target_info" metric, on top of converting
  # them into the "instance" and "job" labels.
  [ keep_identifying_resource_attributes: <boolean> | default = false ]
  # Configures optional translation of OTLP explicit bucket histograms into native histograms with custom buckets.
  [ convert_histograms_to_nhcb: <boolean> | default = false ]

# Settings related to the remote read feature.
remote_read:
  [ - <remote_read> ... ]

# Storage related settings that are runtime reloadable.
storage:
  [ tsdb: <tsdb> ]
  [ exemplars: <exemplars> ]

# Configures exporting traces.
tracing:
  [ <tracing_config> ]
<scrape_config>
A scrape_config section specifies a set of targets and parameters describing how to scrape them. In the general case, one scrape configuration specifies a single job. In advanced configurations, this may change.

Targets may be statically configured via the static_configs parameter or dynamically discovered using one of the supported service-discovery mechanisms.

Additionally, relabel_configs allow advanced modifications to any target and its labels before scraping.

# The job name assigned to scraped metrics by default.
job_name: <job_name>

# How frequently to scrape targets from this job.
[ scrape_interval: <duration> | default = <global_config.scrape_interval> ]

# Per-scrape timeout when scraping this job.
# It cannot be greater than the scrape interval.
[ scrape_timeout: <duration> | default = <global_config.scrape_timeout> ]

# The protocols to negotiate during a scrape with the client.
# Supported values (case sensitive): PrometheusProto, OpenMetricsText0.0.1,
# OpenMetricsText1.0.0, PrometheusText0.0.4, PrometheusText1.0.0.
[ scrape_protocols: [<string>, ...] | default = <global_config.scrape_protocols> ]

# Fallback protocol to use if a scrape returns blank, unparseable, or otherwise
# invalid Content-Type.
# Supported values (case sensitive): PrometheusProto, OpenMetricsText0.0.1,
# OpenMetricsText1.0.0, PrometheusText0.0.4, PrometheusText1.0.0.
[ fallback_scrape_protocol: <string> ]

# Whether to scrape a classic histogram, even if it is also exposed as a native
# histogram (has no effect without --enable-feature=native-histograms).
[ always_scrape_classic_histograms: <boolean> |
default = <global.always_scrape_classic_hisotgrams> ]

# The HTTP resource path on which to fetch metrics from targets.
[ metrics_path: <path> | default = /metrics ]

# honor_labels controls how Prometheus handles conflicts between labels that are
# already present in scraped data and labels that Prometheus would attach
# server-side ("job" and "instance" labels, manually configured target
# labels, and labels generated by service discovery implementations).
#
# If honor_labels is set to "true", label conflicts are resolved by keeping label
# values from the scraped data and ignoring the conflicting server-side labels.
#
# If honor_labels is set to "false", label conflicts are resolved by renaming
# conflicting labels in the scraped data to "exported_<original-label>" (for
# example "exported_instance", "exported_job") and then attaching server-side
# labels.
#
# Setting honor_labels to "true" is useful for use cases such as federation and
# scraping the Pushgateway, where all labels specified in the target should be
# preserved.
#
# Note that any globally configured "external_labels" are unaffected by this
# setting. In communication with external systems, they are always applied only
# when a time series does not have a given label yet and are ignored otherwise.
[ honor_labels: <boolean> | default = false ]

# honor_timestamps controls whether Prometheus respects the timestamps present
# in scraped data.
#
# If honor_timestamps is set to "true", the timestamps of the metrics exposed
# by the target will be used.
#
# If honor_timestamps is set to "false", the timestamps of the metrics exposed
# by the target will be ignored.
[ honor_timestamps: <boolean> | default = true ]

# track_timestamps_staleness controls whether Prometheus tracks staleness of
# the metrics that have an explicit timestamps present in scraped data.
#
# If track_timestamps_staleness is set to "true", a staleness marker will be
# inserted in the TSDB when a metric is no longer present or the target
# is down.
[ track_timestamps_staleness: <boolean> | default = false ]

# Configures the protocol scheme used for requests.
[ scheme: <scheme> | default = http ]

# Optional HTTP URL parameters.
params:
  [ <string>: [<string>, ...] ]

# If enable_compression is set to "false", Prometheus will request uncompressed
# response from the scraped target.
[ enable_compression: <boolean> | default = true ]

# File to which scrape failures are logged.
# Reloading the configuration will reopen the file.
[ scrape_failure_log_file: <string> ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]

# List of Azure service discovery configurations.
azure_sd_configs:
  [ - <azure_sd_config> ... ]

# List of Consul service discovery configurations.
consul_sd_configs:
  [ - <consul_sd_config> ... ]

# List of DigitalOcean service discovery configurations.
digitalocean_sd_configs:
  [ - <digitalocean_sd_config> ... ]

# List of Docker service discovery configurations.
docker_sd_configs:
  [ - <docker_sd_config> ... ]

# List of Docker Swarm service discovery configurations.
dockerswarm_sd_configs:
  [ - <dockerswarm_sd_config> ... ]

# List of DNS service discovery configurations.
dns_sd_configs:
  [ - <dns_sd_config> ... ]

# List of EC2 service discovery configurations.
ec2_sd_configs:
  [ - <ec2_sd_config> ... ]

# List of Eureka service discovery configurations.
eureka_sd_configs:
  [ - <eureka_sd_config> ... ]

# List of file service discovery configurations.
file_sd_configs:
  [ - <file_sd_config> ... ]

# List of GCE service discovery configurations.
gce_sd_configs:
  [ - <gce_sd_config> ... ]

# List of Hetzner service discovery configurations.
hetzner_sd_configs:
  [ - <hetzner_sd_config> ... ]

# List of HTTP service discovery configurations.
http_sd_configs:
  [ - <http_sd_config> ... ]


# List of IONOS service discovery configurations.
ionos_sd_configs:
  [ - <ionos_sd_config> ... ]

# List of Kubernetes service discovery configurations.
kubernetes_sd_configs:
  [ - <kubernetes_sd_config> ... ]

# List of Kuma service discovery configurations.
kuma_sd_configs:
  [ - <kuma_sd_config> ... ]

# List of Lightsail service discovery configurations.
lightsail_sd_configs:
  [ - <lightsail_sd_config> ... ]

# List of Linode service discovery configurations.
linode_sd_configs:
  [ - <linode_sd_config> ... ]

# List of Marathon service discovery configurations.
marathon_sd_configs:
  [ - <marathon_sd_config> ... ]

# List of AirBnB's Nerve service discovery configurations.
nerve_sd_configs:
  [ - <nerve_sd_config> ... ]

# List of Nomad service discovery configurations.
nomad_sd_configs:
  [ - <nomad_sd_config> ... ]

# List of OpenStack service discovery configurations.
openstack_sd_configs:
  [ - <openstack_sd_config> ... ]

# List of OVHcloud service discovery configurations.
ovhcloud_sd_configs:
  [ - <ovhcloud_sd_config> ... ]

# List of PuppetDB service discovery configurations.
puppetdb_sd_configs:
  [ - <puppetdb_sd_config> ... ]

# List of Scaleway service discovery configurations.
scaleway_sd_configs:
  [ - <scaleway_sd_config> ... ]

# List of Zookeeper Serverset service discovery configurations.
serverset_sd_configs:
  [ - <serverset_sd_config> ... ]

# List of STACKIT service discovery configurations.
stackit_sd_configs:
  [ - <stackit_sd_config> ... ]

# List of Triton service discovery configurations.
triton_sd_configs:
  [ - <triton_sd_config> ... ]

# List of Uyuni service discovery configurations.
uyuni_sd_configs:
  [ - <uyuni_sd_config> ... ]

# List of labeled statically configured targets for this job.
static_configs:
  [ - <static_config> ... ]

# List of target relabel configurations.
relabel_configs:
  [ - <relabel_config> ... ]

# List of metric relabel configurations.
metric_relabel_configs:
  [ - <relabel_config> ... ]

# An uncompressed response body larger than this many bytes will cause the
# scrape to fail. 0 means no limit. Example: 100MB.
# This is an experimental feature, this behaviour could
# change or be removed in the future.
[ body_size_limit: <size> | default = 0 ]

# Per-scrape limit on the number of scraped samples that will be accepted.
# If more than this number of samples are present after metric relabeling
# the entire scrape will be treated as failed. 0 means no limit.
[ sample_limit: <int> | default = 0 ]

# Limit on the number of labels that will be accepted per sample. If more
# than this number of labels are present on any sample post metric-relabeling,
# the entire scrape will be treated as failed. 0 means no limit.
[ label_limit: <int> | default = 0 ]

# Limit on the length (in bytes) of each individual label name. If any label
# name in a scrape is longer than this number post metric-relabeling, the
# entire scrape will be treated as failed. Note that label names are UTF-8
# encoded, and characters can take up to 4 bytes. 0 means no limit.
[ label_name_length_limit: <int> | default = 0 ]

# Limit on the length (in bytes) of each individual label value. If any label
# value in a scrape is longer than this number post metric-relabeling, the
# entire scrape will be treated as failed. Note that label values are UTF-8
# encoded, and characters can take up to 4 bytes. 0 means no limit.
[ label_value_length_limit: <int> | default = 0 ]

# Limit per scrape config on number of unique targets that will be
# accepted. If more than this number of targets are present after target
# relabeling, Prometheus will mark the targets as failed without scraping them.
# 0 means no limit. This is an experimental feature, this behaviour could
# change in the future.
[ target_limit: <int> | default = 0 ]

# Limit per scrape config on the number of targets dropped by relabeling
# that will be kept in memory. 0 means no limit.
[ keep_dropped_targets: <int> | default = 0 ]

# Specifies the validation scheme for metric and label names. Either blank or
# "utf8" for full UTF-8 support, or "legacy" for letters, numbers, colons, and
# underscores.
[ metric_name_validation_scheme: <string> | default "utf8" ]

# Specifies the character escaping scheme that will be requested when scraping
# for metric and label names that do not conform to the legacy Prometheus
# character set. Available options are:
#   * `allow-utf-8`: Full UTF-8 support, no escaping needed.
#   * `underscores`: Escape all legacy-invalid characters to underscores.
#   * `dots`: Escapes dots to `_dot_`, underscores to `__`, and all other
#     legacy-invalid characters to underscores.
#   * `values`: Prepend the name with `U__` and replace all invalid
#     characters with their unicode value, surrounded by underscores. Single
#     underscores are replaced with double underscores.
#     e.g. "U__my_2e_dotted_2e_name".
# If this value is left blank, Prometheus will default to `allow-utf-8` if the
# validation scheme for the current scrape config is set to utf8, or
# `underscores` if the validation scheme is set to `legacy`.
[ metric_name_escaping_scheme: <string> | default "allow-utf-8" ]

# Limit on total number of positive and negative buckets allowed in a single
# native histogram. The resolution of a histogram with more buckets will be
# reduced until the number of buckets is within the limit. If the limit cannot
# be reached, the scrape will fail.
# 0 means no limit.
[ native_histogram_bucket_limit: <int> | default = 0 ]

# Lower limit for the growth factor of one bucket to the next in each native
# histogram. The resolution of a histogram with a lower growth factor will be
# reduced as much as possible until it is within the limit.
# To set an upper limit for the schema (equivalent to "scale" in OTel's
# exponential histograms), use the following factor limits:
#
# +----------------------------+----------------------------+
# |        growth factor       | resulting schema AKA scale |
# +----------------------------+----------------------------+
# |          65536             |             -4             |
# +----------------------------+----------------------------+
# |            256             |             -3             |
# +----------------------------+----------------------------+
# |             16             |             -2             |
# +----------------------------+----------------------------+
# |              4             |             -1             |
# +----------------------------+----------------------------+
# |              2             |              0             |
# +----------------------------+----------------------------+
# |              1.4           |              1             |
# +----------------------------+----------------------------+
# |              1.1           |              2             |
# +----------------------------+----------------------------+
# |              1.09          |              3             |
# +----------------------------+----------------------------+
# |              1.04          |              4             |
# +----------------------------+----------------------------+
# |              1.02          |              5             |
# +----------------------------+----------------------------+
# |              1.01          |              6             |
# +----------------------------+----------------------------+
# |              1.005         |              7             |
# +----------------------------+----------------------------+
# |              1.002         |              8             |
# +----------------------------+----------------------------+
#
# 0 results in the smallest supported factor (which is currently ~1.0027 or
# schema 8, but might change in the future).
[ native_histogram_min_bucket_factor: <float> | default = 0 ]

# Specifies whether to convert classic histograms into native histograms with
# custom buckets (has no effect without --enable-feature=native-histograms).
[ convert_classic_histograms_to_nhcb: <bool> | default =
<global.convert_classic_histograms_to_nhcb>]
Where <job_name> must be unique across all scrape configurations.

<http_config>
A http_config allows configuring HTTP requests.

# Sets the `Authorization` header on every request with the
# configured username and password.
# username and username_file are mutually exclusive.
# password and password_file are mutually exclusive.
basic_auth:
  [ username: <string> ]
  [ username_file: <string> ]
  [ password: <secret> ]
  [ password_file: <string> ]

# Sets the `Authorization` header on every request with
# the configured credentials.
authorization:
  # Sets the authentication type of the request.
  [ type: <string> | default: Bearer ]
  # Sets the credentials of the request. It is mutually exclusive with
  # `credentials_file`.
  [ credentials: <secret> ]
  # Sets the credentials of the request with the credentials read from the
  # configured file. It is mutually exclusive with `credentials`.
  [ credentials_file: <filename> ]

# Optional OAuth 2.0 configuration.
# Cannot be used at the same time as basic_auth or authorization.
oauth2:
  [ <oauth2> ]

# Configure whether requests follow HTTP 3xx redirects.
[ follow_redirects: <boolean> | default = true ]

# Whether to enable HTTP2.
[ enable_http2: <boolean> | default: true ]

# Configures the request's TLS settings.
tls_config:
  [ <tls_config> ]

# Optional proxy URL.
[ proxy_url: <string> ]
# Comma-separated string that can contain IPs, CIDR notation, domain names
# that should be excluded from proxying. IP and domain names can
# contain port numbers.
[ no_proxy: <string> ]
# Use proxy URL indicated by environment variables (HTTP_PROXY, https_proxy, HTTPs_PROXY, https_proxy, and no_proxy)
[ proxy_from_environment: <boolean> | default: false ]
# Specifies headers to send to proxies during CONNECT requests.
[ proxy_connect_header:
  [ <string>: [<secret>, ...] ] ]

# Custom HTTP headers to be sent along with each request.
# Headers that are set by Prometheus itself can't be overwritten.
http_headers:
  # Header name.
  [ <string>:
    # Header values.
    [ values: [<string>, ...] ]
    # Headers values. Hidden in configuration page.
    [ secrets: [<secret>, ...] ]
    # Files to read header values from.
    [ files: [<string>, ...] ] ]
<tls_config>
A tls_config allows configuring TLS connections.

# CA certificate to validate API server certificate with. At most one of ca and ca_file is allowed.
[ ca: <string> ]
[ ca_file: <filename> ]

# Certificate and key for client cert authentication to the server.
# At most one of cert and cert_file is allowed.
# At most one of key and key_file is allowed.
[ cert: <string> ]
[ cert_file: <filename> ]
[ key: <secret> ]
[ key_file: <filename> ]

# ServerName extension to indicate the name of the server.
# https://tools.ietf.org/html/rfc4366#section-3.1
[ server_name: <string> ]

# Disable validation of the server certificate.
[ insecure_skip_verify: <boolean> ]

# Minimum acceptable TLS version. Accepted values: TLS10 (TLS 1.0), TLS11 (TLS
# 1.1), TLS12 (TLS 1.2), TLS13 (TLS 1.3).
# If unset, Prometheus will use Go default minimum version, which is TLS 1.2.
# See MinVersion in https://pkg.go.dev/crypto/tls#Config.
[ min_version: <string> ]
# Maximum acceptable TLS version. Accepted values: TLS10 (TLS 1.0), TLS11 (TLS
# 1.1), TLS12 (TLS 1.2), TLS13 (TLS 1.3).
# If unset, Prometheus will use Go default maximum version, which is TLS 1.3.
# See MaxVersion in https://pkg.go.dev/crypto/tls#Config.
[ max_version: <string> ]
<oauth2>
OAuth 2.0 authentication using the client credentials or password grant type. Prometheus fetches an access token from the specified endpoint with the given client access and secret keys.

client_id: <string>
[ client_secret: <secret> ]

# Read the client secret from a file.
# It is mutually exclusive with `client_secret`.
[ client_secret_file: <filename> ]

# Scopes for the token request.
scopes:
  [ - <string> ... ]

# The URL to fetch the token from.
token_url: <string>

# Optional parameters to append to the token URL.
# To set 'password' grant type, add it to params:
# endpoint_params:
#   grant_type: 'password'
#   username: 'username@example.com'
#   password: 'strongpassword'
endpoint_params:
  [ <string>: <string> ... ]

# Configures the token request's TLS settings.
tls_config:
  [ <tls_config> ]

# Optional proxy URL.
[ proxy_url: <string> ]
# Comma-separated string that can contain IPs, CIDR notation, domain names
# that should be excluded from proxying. IP and domain names can
# contain port numbers.
[ no_proxy: <string> ]
# Use proxy URL indicated by environment variables (HTTP_PROXY, https_proxy, HTTPs_PROXY, https_proxy, and no_proxy)
[ proxy_from_environment: <boolean> | default: false ]
# Specifies headers to send to proxies during CONNECT requests.
[ proxy_connect_header:
  [ <string>: [<secret>, ...] ] ]

# Custom HTTP headers to be sent along with each request.
# Headers that are set by Prometheus itself can't be overwritten.
http_headers:
  # Header name.
  [ <string>:
    # Header values.
    [ values: [<string>, ...] ]
    # Headers values. Hidden in configuration page.
    [ secrets: [<secret>, ...] ]
    # Files to read header values from.
    [ files: [<string>, ...] ] ]
<azure_sd_config>
Azure SD configurations allow retrieving scrape targets from Azure VMs.

The discovery requires at least the following permissions:

Microsoft.Compute/virtualMachines/read: Required for VM discovery
Microsoft.Network/networkInterfaces/read: Required for VM discovery
Microsoft.Compute/virtualMachineScaleSets/virtualMachines/read: Required for scale set (VMSS) discovery
Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces/read: Required for scale set (VMSS) discovery
The following meta labels are available on targets during relabeling:

__meta_azure_machine_id: the machine ID
__meta_azure_machine_location: the location the machine runs in
__meta_azure_machine_name: the machine name
__meta_azure_machine_computer_name: the machine computer name
__meta_azure_machine_os_type: the machine operating system
__meta_azure_machine_private_ip: the machine's private IP
__meta_azure_machine_public_ip: the machine's public IP if it exists
__meta_azure_machine_resource_group: the machine's resource group
__meta_azure_machine_tag_<tagname>: each tag value of the machine
__meta_azure_machine_scale_set: the name of the scale set which the vm is part of (this value is only set if you are using a scale set)
__meta_azure_machine_size: the machine size
__meta_azure_subscription_id: the subscription ID
__meta_azure_tenant_id: the tenant ID
See below for the configuration options for Azure discovery:

# The information to access the Azure API.
# The Azure environment.
[ environment: <string> | default = AzurePublicCloud ]

# The authentication method, either OAuth, ManagedIdentity or SDK.
# See https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview
# SDK authentication method uses environment variables by default.
# See https://learn.microsoft.com/en-us/azure/developer/go/azure-sdk-authentication
[ authentication_method: <string> | default = OAuth]
# The subscription ID. Always required.
subscription_id: <string>
# Optional tenant ID. Only required with authentication_method OAuth.
[ tenant_id: <string> ]
# Optional client ID. Only required with authentication_method OAuth.
[ client_id: <string> ]
# Optional client secret. Only required with authentication_method OAuth.
[ client_secret: <secret> ]

# Optional resource group name. Limits discovery to this resource group.
[ resource_group: <string> ]

# Refresh interval to re-read the instance list.
[ refresh_interval: <duration> | default = 300s ]

# The port to scrape metrics from. If using the public IP address, this must
# instead be specified in the relabeling rule.
[ port: <int> | default = 80 ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<consul_sd_config>
Consul SD configurations allow retrieving scrape targets from Consul's Catalog API.

The following meta labels are available on targets during relabeling:

__meta_consul_address: the address of the target
__meta_consul_dc: the datacenter name for the target
__meta_consul_health: the health status of the service
__meta_consul_partition: the admin partition name where the service is registered
__meta_consul_metadata_<key>: each node metadata key value of the target
__meta_consul_node: the node name defined for the target
__meta_consul_service_address: the service address of the target
__meta_consul_service_id: the service ID of the target
__meta_consul_service_metadata_<key>: each service metadata key value of the target
__meta_consul_service_port: the service port of the target
__meta_consul_service: the name of the service the target belongs to
__meta_consul_tagged_address_<key>: each node tagged address key value of the target
__meta_consul_tags: the list of tags of the target joined by the tag separator
# The information to access the Consul API. It is to be defined
# as the Consul documentation requires.
[ server: <host> | default = "localhost:8500" ]
# Prefix for URIs for when consul is behind an API gateway (reverse proxy).
[ path_prefix: <string> ]
[ token: <secret> ]
[ datacenter: <string> ]
# Namespaces are only supported in Consul Enterprise.
[ namespace: <string> ]
# Admin Partitions are only supported in Consul Enterprise.
[ partition: <string> ]
[ scheme: <string> | default = "http" ]
# The username and password fields are deprecated in favor of the basic_auth configuration.
[ username: <string> ]
[ password: <secret> ]

# A list of services for which targets are retrieved. If omitted, all services
# are scraped.
services:
  [ - <string> ]

# A Consul Filter expression used to filter the catalog results
# See https://www.consul.io/api-docs/catalog#list-services to know more
# about the filter expressions that can be used.
[ filter: <string> ]

# The `tags` and `node_meta` fields are deprecated in Consul in favor of `filter`.
# An optional list of tags used to filter nodes for a given service. Services must contain all tags in the list.
tags:
  [ - <string> ]

# Node metadata key/value pairs to filter nodes for a given service. As of Consul 1.14, consider `filter` instead.
[ node_meta:
  [ <string>: <string> ... ] ]

# The string by which Consul tags are joined into the tag label.
[ tag_separator: <string> | default = , ]

# Allow stale Consul results (see https://www.consul.io/api/features/consistency.html). Will reduce load on Consul.
[ allow_stale: <boolean> | default = true ]

# The time after which the provided names are refreshed.
# On large setup it might be a good idea to increase this value because the catalog will change all the time.
[ refresh_interval: <duration> | default = 30s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
Note that the IP number and port used to scrape the targets is assembled as <__meta_consul_address>:<__meta_consul_service_port>. However, in some Consul setups, the relevant address is in __meta_consul_service_address. In those cases, you can use the relabel feature to replace the special __address__ label.

The relabeling phase is the preferred and more powerful way to filter services or nodes for a service based on arbitrary labels. For users with thousands of services it can be more efficient to use the Consul API directly which has basic support for filtering nodes (currently by node metadata and a single tag).

<digitalocean_sd_config>
DigitalOcean SD configurations allow retrieving scrape targets from DigitalOcean's Droplets API. This service discovery uses the public IPv4 address by default, by that can be changed with relabeling, as demonstrated in the Prometheus digitalocean-sd configuration file.

The following meta labels are available on targets during relabeling:

__meta_digitalocean_droplet_id: the id of the droplet
__meta_digitalocean_droplet_name: the name of the droplet
__meta_digitalocean_image: the slug of the droplet's image
__meta_digitalocean_image_name: the display name of the droplet's image
__meta_digitalocean_private_ipv4: the private IPv4 of the droplet
__meta_digitalocean_public_ipv4: the public IPv4 of the droplet
__meta_digitalocean_public_ipv6: the public IPv6 of the droplet
__meta_digitalocean_region: the region of the droplet
__meta_digitalocean_size: the size of the droplet
__meta_digitalocean_status: the status of the droplet
__meta_digitalocean_features: the comma-separated list of features of the droplet
__meta_digitalocean_tags: the comma-separated list of tags of the droplet
__meta_digitalocean_vpc: the id of the droplet's VPC
# The port to scrape metrics from.
[ port: <int> | default = 80 ]

# The time after which the droplets are refreshed.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<docker_sd_config>
Docker SD configurations allow retrieving scrape targets from Docker Engine hosts.

This SD discovers "containers" and will create a target for each network IP and port the container is configured to expose.

Available meta labels:

__meta_docker_container_id: the id of the container
__meta_docker_container_name: the name of the container
__meta_docker_container_network_mode: the network mode of the container
__meta_docker_container_label_<labelname>: each label of the container, with any unsupported characters converted to an underscore
__meta_docker_network_id: the ID of the network
__meta_docker_network_name: the name of the network
__meta_docker_network_ingress: whether the network is ingress
__meta_docker_network_internal: whether the network is internal
__meta_docker_network_label_<labelname>: each label of the network, with any unsupported characters converted to an underscore
__meta_docker_network_scope: the scope of the network
__meta_docker_network_ip: the IP of the container in this network
__meta_docker_port_private: the port on the container
__meta_docker_port_public: the external port if a port-mapping exists
__meta_docker_port_public_ip: the public IP if a port-mapping exists
See below for the configuration options for Docker discovery:

# Address of the Docker daemon.
host: <string>

# The port to scrape metrics from, when `role` is nodes, and for discovered
# tasks and services that don't have published ports.
[ port: <int> | default = 80 ]

# The host to use if the container is in host networking mode.
[ host_networking_host: <string> | default = "localhost" ]

# Sort all non-nil networks in ascending order based on network name and
# get the first network if the container has multiple networks defined,
# thus avoiding collecting duplicate targets.
[ match_first_network: <boolean> | default = true ]

# Optional filters to limit the discovery process to a subset of available
# resources.
# The available filters are listed in the upstream documentation:
# https://docs.docker.com/engine/api/v1.40/#operation/ContainerList
[ filters:
  [ - name: <string>
      values: <string>, [...] ]

# The time after which the containers are refreshed.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
The relabeling phase is the preferred and more powerful way to filter containers. For users with thousands of containers it can be more efficient to use the Docker API directly which has basic support for filtering containers (using filters).

See this example Prometheus configuration file for a detailed example of configuring Prometheus for Docker Engine.

<dockerswarm_sd_config>
Docker Swarm SD configurations allow retrieving scrape targets from Docker Swarm engine.

One of the following roles can be configured to discover targets:

services
The services role discovers all Swarm services and exposes their ports as targets. For each published port of a service, a single target is generated. If a service has no published ports, a target per service is created using the port parameter defined in the SD configuration.

Available meta labels:

__meta_dockerswarm_service_id: the id of the service
__meta_dockerswarm_service_name: the name of the service
__meta_dockerswarm_service_mode: the mode of the service
__meta_dockerswarm_service_endpoint_port_name: the name of the endpoint port, if available
__meta_dockerswarm_service_endpoint_port_publish_mode: the publish mode of the endpoint port
__meta_dockerswarm_service_label_<labelname>: each label of the service, with any unsupported characters converted to an underscore
__meta_dockerswarm_service_task_container_hostname: the container hostname of the target, if available
__meta_dockerswarm_service_task_container_image: the container image of the target
__meta_dockerswarm_service_updating_status: the status of the service, if available
__meta_dockerswarm_network_id: the ID of the network
__meta_dockerswarm_network_name: the name of the network
__meta_dockerswarm_network_ingress: whether the network is ingress
__meta_dockerswarm_network_internal: whether the network is internal
__meta_dockerswarm_network_label_<labelname>: each label of the network, with any unsupported characters converted to an underscore
__meta_dockerswarm_network_scope: the scope of the network
tasks
The tasks role discovers all Swarm tasks and exposes their ports as targets. For each published port of a task, a single target is generated. If a task has no published ports, a target per task is created using the port parameter defined in the SD configuration.

Available meta labels:

__meta_dockerswarm_container_label_<labelname>: each label of the container, with any unsupported characters converted to an underscore
__meta_dockerswarm_task_id: the id of the task
__meta_dockerswarm_task_container_id: the container id of the task
__meta_dockerswarm_task_desired_state: the desired state of the task
__meta_dockerswarm_task_slot: the slot of the task
__meta_dockerswarm_task_state: the state of the task
__meta_dockerswarm_task_port_publish_mode: the publish mode of the task port
__meta_dockerswarm_service_id: the id of the service
__meta_dockerswarm_service_name: the name of the service
__meta_dockerswarm_service_mode: the mode of the service
__meta_dockerswarm_service_label_<labelname>: each label of the service, with any unsupported characters converted to an underscore
__meta_dockerswarm_network_id: the ID of the network
__meta_dockerswarm_network_name: the name of the network
__meta_dockerswarm_network_ingress: whether the network is ingress
__meta_dockerswarm_network_internal: whether the network is internal
__meta_dockerswarm_network_label_<labelname>: each label of the network, with any unsupported characters converted to an underscore
__meta_dockerswarm_network_label: each label of the network, with any unsupported characters converted to an underscore
__meta_dockerswarm_network_scope: the scope of the network
__meta_dockerswarm_node_id: the ID of the node
__meta_dockerswarm_node_hostname: the hostname of the node
__meta_dockerswarm_node_address: the address of the node
__meta_dockerswarm_node_availability: the availability of the node
__meta_dockerswarm_node_label_<labelname>: each label of the node, with any unsupported characters converted to an underscore
__meta_dockerswarm_node_platform_architecture: the architecture of the node
__meta_dockerswarm_node_platform_os: the operating system of the node
__meta_dockerswarm_node_role: the role of the node
__meta_dockerswarm_node_status: the status of the node
The __meta_dockerswarm_network_* meta labels are not populated for ports which are published with mode=host.

nodes
The nodes role is used to discover Swarm nodes.

Available meta labels:

__meta_dockerswarm_node_address: the address of the node
__meta_dockerswarm_node_availability: the availability of the node
__meta_dockerswarm_node_engine_version: the version of the node engine
__meta_dockerswarm_node_hostname: the hostname of the node
__meta_dockerswarm_node_id: the ID of the node
__meta_dockerswarm_node_label_<labelname>: each label of the node, with any unsupported characters converted to an underscore
__meta_dockerswarm_node_manager_address: the address of the manager component of the node
__meta_dockerswarm_node_manager_leader: the leadership status of the manager component of the node (true or false)
__meta_dockerswarm_node_manager_reachability: the reachability of the manager component of the node
__meta_dockerswarm_node_platform_architecture: the architecture of the node
__meta_dockerswarm_node_platform_os: the operating system of the node
__meta_dockerswarm_node_role: the role of the node
__meta_dockerswarm_node_status: the status of the node
See below for the configuration options for Docker Swarm discovery:

# Address of the Docker daemon.
host: <string>

# Role of the targets to retrieve. Must be `services`, `tasks`, or `nodes`.
role: <string>

# The port to scrape metrics from, when `role` is nodes, and for discovered
# tasks and services that don't have published ports.
[ port: <int> | default = 80 ]

# Optional filters to limit the discovery process to a subset of available
# resources.
# The available filters are listed in the upstream documentation:
# Services: https://docs.docker.com/engine/api/v1.40/#operation/ServiceList
# Tasks: https://docs.docker.com/engine/api/v1.40/#operation/TaskList
# Nodes: https://docs.docker.com/engine/api/v1.40/#operation/NodeList
[ filters:
  [ - name: <string>
      values: <string>, [...] ]

# The time after which the service discovery data is refreshed.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
The relabeling phase is the preferred and more powerful way to filter tasks, services or nodes. For users with thousands of tasks it can be more efficient to use the Swarm API directly which has basic support for filtering nodes (using filters).

See this example Prometheus configuration file for a detailed example of configuring Prometheus for Docker Swarm.

<dns_sd_config>
A DNS-based service discovery configuration allows specifying a set of DNS domain names which are periodically queried to discover a list of targets. The DNS servers to be contacted are read from /etc/resolv.conf.

This service discovery method only supports basic DNS A, AAAA, MX, NS and SRV record queries, but not the advanced DNS-SD approach specified in RFC6763.

The following meta labels are available on targets during relabeling:

__meta_dns_name: the record name that produced the discovered target.
__meta_dns_srv_record_target: the target field of the SRV record
__meta_dns_srv_record_port: the port field of the SRV record
__meta_dns_mx_record_target: the target field of the MX record
__meta_dns_ns_record_target: the target field of the NS record
# A list of DNS domain names to be queried.
names:
  [ - <string> ]

# The type of DNS query to perform. One of SRV, A, AAAA, MX or NS.
[ type: <string> | default = 'SRV' ]

# The port number used if the query type is not SRV.
[ port: <int>]

# The time after which the provided names are refreshed.
[ refresh_interval: <duration> | default = 30s ]
<ec2_sd_config>
EC2 SD configurations allow retrieving scrape targets from AWS EC2 instances. The private IP address is used by default, but may be changed to the public IP address with relabeling.

The IAM credentials used must have the ec2:DescribeInstances permission to discover scrape targets, and may optionally have the ec2:DescribeAvailabilityZones permission if you want the availability zone ID available as a label (see below).

The following meta labels are available on targets during relabeling:

__meta_ec2_ami: the EC2 Amazon Machine Image
__meta_ec2_architecture: the architecture of the instance
__meta_ec2_availability_zone: the availability zone in which the instance is running
__meta_ec2_availability_zone_id: the availability zone ID in which the instance is running (requires ec2:DescribeAvailabilityZones)
__meta_ec2_instance_id: the EC2 instance ID
__meta_ec2_instance_lifecycle: the lifecycle of the EC2 instance, set only for 'spot' or 'scheduled' instances, absent otherwise
__meta_ec2_instance_state: the state of the EC2 instance
__meta_ec2_instance_type: the type of the EC2 instance
__meta_ec2_ipv6_addresses: comma separated list of IPv6 addresses assigned to the instance's network interfaces, if present
__meta_ec2_owner_id: the ID of the AWS account that owns the EC2 instance
__meta_ec2_platform: the Operating System platform, set to 'windows' on Windows servers, absent otherwise
__meta_ec2_primary_ipv6_addresses: comma separated list of the Primary IPv6 addresses of the instance, if present. The list is ordered based on the position of each corresponding network interface in the attachment order.
__meta_ec2_primary_subnet_id: the subnet ID of the primary network interface, if available
__meta_ec2_private_dns_name: the private DNS name of the instance, if available
__meta_ec2_private_ip: the private IP address of the instance, if present
__meta_ec2_public_dns_name: the public DNS name of the instance, if available
__meta_ec2_public_ip: the public IP address of the instance, if available
__meta_ec2_region: the region of the instance
__meta_ec2_subnet_id: comma separated list of subnets IDs in which the instance is running, if available
__meta_ec2_tag_<tagkey>: each tag value of the instance
__meta_ec2_vpc_id: the ID of the VPC in which the instance is running, if available
See below for the configuration options for EC2 discovery:

# The information to access the EC2 API.

# The AWS region. If blank, the region from the instance metadata is used.
[ region: <string> ]

# Custom endpoint to be used.
[ endpoint: <string> ]

# The AWS API keys. If blank, the environment variables `AWS_ACCESS_KEY_ID`
# and `AWS_SECRET_ACCESS_KEY` are used.
[ access_key: <string> ]
[ secret_key: <secret> ]
# Named AWS profile used to connect to the API.
[ profile: <string> ]

# AWS Role ARN, an alternative to using AWS API keys.
[ role_arn: <string> ]

# Refresh interval to re-read the instance list.
[ refresh_interval: <duration> | default = 60s ]

# The port to scrape metrics from. If using the public IP address, this must
# instead be specified in the relabeling rule.
[ port: <int> | default = 80 ]

# Filters can be used optionally to filter the instance list by other criteria.
# Available filter criteria can be found here:
# https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstances.html
# Filter API documentation: https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_Filter.html
filters:
  [ - name: <string>
      values: <string>, [...] ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
The relabeling phase is the preferred and more powerful way to filter targets based on arbitrary labels. For users with thousands of instances it can be more efficient to use the EC2 API directly which has support for filtering instances.

<openstack_sd_config>
OpenStack SD configurations allow retrieving scrape targets from OpenStack Nova instances.

One of the following <openstack_role> types can be configured to discover targets:

hypervisor
The hypervisor role discovers one target per Nova hypervisor node. The target address defaults to the host_ip attribute of the hypervisor.

The following meta labels are available on targets during relabeling:

__meta_openstack_hypervisor_host_ip: the hypervisor node's IP address.
__meta_openstack_hypervisor_hostname: the hypervisor node's name.
__meta_openstack_hypervisor_id: the hypervisor node's ID.
__meta_openstack_hypervisor_state: the hypervisor node's state.
__meta_openstack_hypervisor_status: the hypervisor node's status.
__meta_openstack_hypervisor_type: the hypervisor node's type.
instance
The instance role discovers one target per network interface of Nova instance. The target address defaults to the private IP address of the network interface.

The following meta labels are available on targets during relabeling:

__meta_openstack_address_pool: the pool of the private IP.
__meta_openstack_instance_flavor: the flavor name of the OpenStack instance, or the flavor ID if the flavor name isn't available.
__meta_openstack_instance_id: the OpenStack instance ID.
__meta_openstack_instance_image: the ID of the image the OpenStack instance is using.
__meta_openstack_instance_name: the OpenStack instance name.
__meta_openstack_instance_status: the status of the OpenStack instance.
__meta_openstack_private_ip: the private IP of the OpenStack instance.
__meta_openstack_project_id: the project (tenant) owning this instance.
__meta_openstack_public_ip: the public IP of the OpenStack instance.
__meta_openstack_tag_<key>: each metadata item of the instance, with any unsupported characters converted to an underscore.
__meta_openstack_user_id: the user account owning the tenant.
loadbalancer
The loadbalancer role discovers one target per Octavia loadbalancer with a PROMETHEUS listener. The target address defaults to the VIP address of the load balancer.

The following meta labels are available on targets during relabeling:

__meta_openstack_loadbalancer_availability_zone: the availability zone of the OpenStack load balancer.
__meta_openstack_loadbalancer_floating_ip: the floating IP of the OpenStack load balancer.
__meta_openstack_loadbalancer_id: the OpenStack load balancer ID.
__meta_openstack_loadbalancer_name: the OpenStack load balancer name.
__meta_openstack_loadbalancer_provider: the Octavia provider of the OpenStack load balancer.
__meta_openstack_loadbalancer_operating_status: the operating status of the OpenStack load balancer.
__meta_openstack_loadbalancer_provisioning_status: the provisioning status of the OpenStack load balancer.
__meta_openstack_loadbalancer_tags: comma separated list of the OpenStack load balancer.
__meta_openstack_loadbalancer_vip: the VIP of the OpenStack load balancer.
__meta_openstack_project_id: the project (tenant) owning this load balancer.
See below for the configuration options for OpenStack discovery:

# The information to access the OpenStack API.

# The OpenStack role of entities that should be discovered.
role: <openstack_role>

# The OpenStack Region.
region: <string>

# identity_endpoint specifies the HTTP endpoint that is required to work with
# the Identity API of the appropriate version. While it's ultimately needed by
# all of the identity services, it will often be populated by a provider-level
# function.
[ identity_endpoint: <string> ]

# username is required if using Identity V2 API. Consult with your provider's
# control panel to discover your account's username. In Identity V3, either
# userid or a combination of username and domain_id or domain_name are needed.
[ username: <string> ]
[ userid: <string> ]

# password for the Identity V2 and V3 APIs. Consult with your provider's
# control panel to discover your account's preferred method of authentication.
[ password: <secret> ]

# At most one of domain_id and domain_name must be provided if using username
# with Identity V3. Otherwise, either are optional.
[ domain_name: <string> ]
[ domain_id: <string> ]

# The project_id and project_name fields are optional for the Identity V2 API.
# Some providers allow you to specify a project_name instead of the project_id.
# Some require both. Your provider's authentication policies will determine
# how these fields influence authentication.
[ project_name: <string> ]
[ project_id: <string> ]

# The application_credential_id or application_credential_name fields are
# required if using an application credential to authenticate. Some providers
# allow you to create an application credential to authenticate rather than a
# password.
[ application_credential_name: <string> ]
[ application_credential_id: <string> ]

# The application_credential_secret field is required if using an application
# credential to authenticate.
[ application_credential_secret: <secret> ]

# Whether the service discovery should list all instances for all projects.
# It is only relevant for the 'instance' role and usually requires admin permissions.
[ all_tenants: <boolean> | default: false ]

# Refresh interval to re-read the instance list.
[ refresh_interval: <duration> | default = 60s ]

# The port to scrape metrics from. If using the public IP address, this must
# instead be specified in the relabeling rule.
[ port: <int> | default = 80 ]

# The availability of the endpoint to connect to. Must be one of public, admin or internal.
[ availability: <string> | default = "public" ]

# TLS configuration.
tls_config:
  [ <tls_config> ]
<ovhcloud_sd_config>
OVHcloud SD configurations allow retrieving scrape targets from OVHcloud's dedicated servers and VPS using their API. Prometheus will periodically check the REST endpoint and create a target for every discovered server. The role will try to use the public IPv4 address as default address, if there's none it will try to use the IPv6 one. This may be changed with relabeling. For OVHcloud's public cloud instances you can use the openstack_sd_config.

VPS
__meta_ovhcloud_vps_cluster: the cluster of the server
__meta_ovhcloud_vps_datacenter: the datacenter of the server
__meta_ovhcloud_vps_disk: the disk of the server
__meta_ovhcloud_vps_display_name: the display name of the server
__meta_ovhcloud_vps_ipv4: the IPv4 of the server
__meta_ovhcloud_vps_ipv6: the IPv6 of the server
__meta_ovhcloud_vps_keymap: the KVM keyboard layout of the server
__meta_ovhcloud_vps_maximum_additional_ip: the maximum additional IPs of the server
__meta_ovhcloud_vps_memory_limit: the memory limit of the server
__meta_ovhcloud_vps_memory: the memory of the server
__meta_ovhcloud_vps_monitoring_ip_blocks: the monitoring IP blocks of the server
__meta_ovhcloud_vps_name: the name of the server
__meta_ovhcloud_vps_netboot_mode: the netboot mode of the server
__meta_ovhcloud_vps_offer_type: the offer type of the server
__meta_ovhcloud_vps_offer: the offer of the server
__meta_ovhcloud_vps_state: the state of the server
__meta_ovhcloud_vps_vcore: the number of virtual cores of the server
__meta_ovhcloud_vps_version: the version of the server
__meta_ovhcloud_vps_zone: the zone of the server
Dedicated servers
__meta_ovhcloud_dedicated_server_commercial_range: the commercial range of the server
__meta_ovhcloud_dedicated_server_datacenter: the datacenter of the server
__meta_ovhcloud_dedicated_server_ipv4: the IPv4 of the server
__meta_ovhcloud_dedicated_server_ipv6: the IPv6 of the server
__meta_ovhcloud_dedicated_server_link_speed: the link speed of the server
__meta_ovhcloud_dedicated_server_name: the name of the server
__meta_ovhcloud_dedicated_server_no_intervention: whether datacenter intervention is disabled for the server
__meta_ovhcloud_dedicated_server_os: the operating system of the server
__meta_ovhcloud_dedicated_server_rack: the rack of the server
__meta_ovhcloud_dedicated_server_reverse: the reverse DNS name of the server
__meta_ovhcloud_dedicated_server_server_id: the ID of the server
__meta_ovhcloud_dedicated_server_state: the state of the server
__meta_ovhcloud_dedicated_server_support_level: the support level of the server
See below for the configuration options for OVHcloud discovery:

# Access key to use. https://api.ovh.com
application_key: <string>
application_secret: <secret>
consumer_key: <secret>
# Service of the targets to retrieve. Must be `vps` or `dedicated_server`.
service: <string>
# API endpoint. https://github.com/ovh/go-ovh#supported-apis
[ endpoint: <string> | default = "ovh-eu" ]
# Refresh interval to re-read the resources list.
[ refresh_interval: <duration> | default = 60s ]
<puppetdb_sd_config>
PuppetDB SD configurations allow retrieving scrape targets from PuppetDB resources.

This SD discovers resources and will create a target for each resource returned by the API.

The resource address is the certname of the resource and can be changed during relabeling.

The following meta labels are available on targets during relabeling:

__meta_puppetdb_query: the Puppet Query Language (PQL) query
__meta_puppetdb_certname: the name of the node associated with the resource
__meta_puppetdb_resource: a SHA-1 hash of the resource’s type, title, and parameters, for identification
__meta_puppetdb_type: the resource type
__meta_puppetdb_title: the resource title
__meta_puppetdb_exported: whether the resource is exported ("true" or "false")
__meta_puppetdb_tags: comma separated list of resource tags
__meta_puppetdb_file: the manifest file in which the resource was declared
__meta_puppetdb_environment: the environment of the node associated with the resource
__meta_puppetdb_parameter_<parametername>: the parameters of the resource
See below for the configuration options for PuppetDB discovery:

# The URL of the PuppetDB root query endpoint.
url: <string>

# Puppet Query Language (PQL) query. Only resources are supported.
# https://puppet.com/docs/puppetdb/latest/api/query/v4/pql.html
query: <string>

# Whether to include the parameters as meta labels.
# Due to the differences between parameter types and Prometheus labels,
# some parameters might not be rendered. The format of the parameters might
# also change in future releases.
#
# Note: Enabling this exposes parameters in the Prometheus UI and API. Make sure
# that you don't have secrets exposed as parameters if you enable this.
[ include_parameters: <boolean> | default = false ]

# Refresh interval to re-read the resources list.
[ refresh_interval: <duration> | default = 60s ]

# The port to scrape metrics from.
[ port: <int> | default = 80 ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
See this example Prometheus configuration file for a detailed example of configuring Prometheus with PuppetDB.

<file_sd_config>
File-based service discovery provides a more generic way to configure static targets and serves as an interface to plug in custom service discovery mechanisms.

It reads a set of files containing a list of zero or more <static_config>s. Changes to all defined files are detected via disk watches and applied immediately.

While those individual files are watched for changes, the parent directory is also watched implicitly. This is to handle atomic renaming efficiently and to detect new files that match the configured globs. This may cause issues if the parent directory contains a large number of other files, as each of these files will be watched too, even though the events related to them are not relevant.

Files may be provided in YAML or JSON format. Only changes resulting in well-formed target groups are applied.

Files must contain a list of static configs, using these formats:

JSON

[
  {
    "targets": [ "<host>", ... ],
    "labels": {
      "<labelname>": "<labelvalue>", ...
    }
  },
  ...
]
YAML

- targets:
  [ - '<host>' ]
  labels:
    [ <labelname>: <labelvalue> ... ]
As a fallback, the file contents are also re-read periodically at the specified refresh interval.

Each target has a meta label __meta_filepath during the relabeling phase. Its value is set to the filepath from which the target was extracted.

There is a list of integrations with this discovery mechanism.

# Patterns for files from which target groups are extracted.
files:
  [ - <filename_pattern> ... ]

# Refresh interval to re-read the files.
[ refresh_interval: <duration> | default = 5m ]
Where <filename_pattern> may be a path ending in .json, .yml or .yaml. The last path segment may contain a single * that matches any character sequence, e.g. my/path/tg_*.json.

<gce_sd_config>
GCE SD configurations allow retrieving scrape targets from GCP GCE instances. The private IP address is used by default, but may be changed to the public IP address with relabeling.

The following meta labels are available on targets during relabeling:

__meta_gce_instance_id: the numeric id of the instance
__meta_gce_instance_name: the name of the instance
__meta_gce_label_<labelname>: each GCE label of the instance, with any unsupported characters converted to an underscore
__meta_gce_machine_type: full or partial URL of the machine type of the instance
__meta_gce_metadata_<name>: each metadata item of the instance
__meta_gce_network: the network URL of the instance
__meta_gce_private_ip: the private IP address of the instance
__meta_gce_interface_ipv4_<name>: IPv4 address of each named interface
__meta_gce_project: the GCP project in which the instance is running
__meta_gce_public_ip: the public IP address of the instance, if present
__meta_gce_subnetwork: the subnetwork URL of the instance
__meta_gce_tags: comma separated list of instance tags
__meta_gce_zone: the GCE zone URL in which the instance is running
See below for the configuration options for GCE discovery:

# The information to access the GCE API.

# The GCP Project
project: <string>

# The zone of the scrape targets. If you need multiple zones use multiple
# gce_sd_configs.
zone: <string>

# Filter can be used optionally to filter the instance list by other criteria
# Syntax of this filter string is described here in the filter query parameter section:
# https://cloud.google.com/compute/docs/reference/latest/instances/list
[ filter: <string> ]

# Refresh interval to re-read the instance list
[ refresh_interval: <duration> | default = 60s ]

# The port to scrape metrics from. If using the public IP address, this must
# instead be specified in the relabeling rule.
[ port: <int> | default = 80 ]

# The tag separator is used to separate the tags on concatenation
[ tag_separator: <string> | default = , ]
Credentials are discovered by the Google Cloud SDK default client by looking in the following places, preferring the first location found:

a JSON file specified by the GOOGLE_APPLICATION_CREDENTIALS environment variable
a JSON file in the well-known path $HOME/.config/gcloud/application_default_credentials.json
fetched from the GCE metadata server
If Prometheus is running within GCE, the service account associated with the instance it is running on should have at least read-only permissions to the compute resources. If running outside of GCE make sure to create an appropriate service account and place the credential file in one of the expected locations.

<hetzner_sd_config>
Hetzner SD configurations allow retrieving scrape targets from Hetzner Cloud API and Robot API. This service discovery uses the public IPv4 address by default, but that can be changed with relabeling, as demonstrated in the Prometheus hetzner-sd configuration file.

The following meta labels are available on all targets during relabeling:

__meta_hetzner_server_id: the ID of the server
__meta_hetzner_server_name: the name of the server
__meta_hetzner_server_status: the status of the server
__meta_hetzner_public_ipv4: the public ipv4 address of the server
__meta_hetzner_public_ipv6_network: the public ipv6 network (/64) of the server
__meta_hetzner_datacenter: the datacenter of the server
The labels below are only available for targets with role set to hcloud:

__meta_hetzner_hcloud_image_name: the image name of the server
__meta_hetzner_hcloud_image_description: the description of the server image
__meta_hetzner_hcloud_image_os_flavor: the OS flavor of the server image
__meta_hetzner_hcloud_image_os_version: the OS version of the server image
__meta_hetzner_hcloud_datacenter_location: the location of the server
__meta_hetzner_hcloud_datacenter_location_network_zone: the network zone of the server
__meta_hetzner_hcloud_server_type: the type of the server
__meta_hetzner_hcloud_cpu_cores: the CPU cores count of the server
__meta_hetzner_hcloud_cpu_type: the CPU type of the server (shared or dedicated)
__meta_hetzner_hcloud_memory_size_gb: the amount of memory of the server (in GB)
__meta_hetzner_hcloud_disk_size_gb: the disk size of the server (in GB)
__meta_hetzner_hcloud_private_ipv4_<networkname>: the private ipv4 address of the server within a given network
__meta_hetzner_hcloud_label_<labelname>: each label of the server, with any unsupported characters converted to an underscore
__meta_hetzner_hcloud_labelpresent_<labelname>: true for each label of the server, with any unsupported characters converted to an underscore
The labels below are only available for targets with role set to robot:

__meta_hetzner_robot_product: the product of the server
__meta_hetzner_robot_cancelled: the server cancellation status
# The Hetzner role of entities that should be discovered.
# One of robot or hcloud.
role: <string>

# The port to scrape metrics from.
[ port: <int> | default = 80 ]

# The time after which the servers are refreshed.
[ refresh_interval: <duration> | default = 60s ]

# Label selector used to filter the servers when fetching them from the API. See https://docs.hetzner.cloud/#label-selector for more details.
# Only used when role is hcloud.
[ label_selector: <string> ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<http_sd_config>
HTTP-based service discovery provides a more generic way to configure static targets and serves as an interface to plug in custom service discovery mechanisms.

It fetches targets from an HTTP endpoint containing a list of zero or more <static_config>s. The target must reply with an HTTP 200 response. The HTTP header Content-Type must be application/json, and the body must be valid JSON.

Example response body:

[
  {
    "targets": [ "<host>", ... ],
    "labels": {
      "<labelname>": "<labelvalue>", ...
    }
  },
  ...
]
The endpoint is queried periodically at the specified refresh interval. The prometheus_sd_http_failures_total counter metric tracks the number of refresh failures.

Each target has a meta label __meta_url during the relabeling phase. Its value is set to the URL from which the target was extracted.

# URL from which the targets are fetched.
url: <string>

# Refresh interval to re-query the endpoint.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<ionos_sd_config>
IONOS SD configurations allows retrieving scrape targets from IONOS Cloud API. This service discovery uses the first NICs IP address by default, but that can be changed with relabeling. The following meta labels are available on all targets during relabeling:

__meta_ionos_server_availability_zone: the availability zone of the server
__meta_ionos_server_boot_cdrom_id: the ID of the CD-ROM the server is booted from
__meta_ionos_server_boot_image_id: the ID of the boot image or snapshot the server is booted from
__meta_ionos_server_boot_volume_id: the ID of the boot volume
__meta_ionos_server_cpu_family: the CPU family of the server to
__meta_ionos_server_id: the ID of the server
__meta_ionos_server_ip: comma separated list of all IPs assigned to the server
__meta_ionos_server_lifecycle: the lifecycle state of the server resource
__meta_ionos_server_name: the name of the server
__meta_ionos_server_nic_ip_<nic_name>: comma separated list of IPs, grouped by the name of each NIC attached to the server
__meta_ionos_server_servers_id: the ID of the servers the server belongs to
__meta_ionos_server_state: the execution state of the server
__meta_ionos_server_type: the type of the server
# The unique ID of the data center.
datacenter_id: <string>

# The port to scrape metrics from.
[ port: <int> | default = 80 ]

# The time after which the servers are refreshed.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<kubernetes_sd_config>
Kubernetes SD configurations allow retrieving scrape targets from Kubernetes' REST API and always staying synchronized with the cluster state.

One of the following role types can be configured to discover targets:

node
The node role discovers one target per cluster node with the address defaulting to the Kubelet's HTTP port. The target address defaults to the first existing address of the Kubernetes node object in the address type order of NodeInternalIP, NodeExternalIP, NodeLegacyHostIP, and NodeHostName.

Available meta labels:

__meta_kubernetes_node_name: The name of the node object.
__meta_kubernetes_node_provider_id: The cloud provider's name for the node object.
__meta_kubernetes_node_label_<labelname>: Each label from the node object, with any unsupported characters converted to an underscore.
__meta_kubernetes_node_labelpresent_<labelname>: true for each label from the node object, with any unsupported characters converted to an underscore.
__meta_kubernetes_node_annotation_<annotationname>: Each annotation from the node object.
__meta_kubernetes_node_annotationpresent_<annotationname>: true for each annotation from the node object.
__meta_kubernetes_node_address_<address_type>: The first address for each node address type, if it exists.
In addition, the instance label for the node will be set to the node name as retrieved from the API server.

service
The service role discovers a target for each service port for each service. This is generally useful for blackbox monitoring of a service. The address will be set to the Kubernetes DNS name of the service and respective service port.

Available meta labels:

__meta_kubernetes_namespace: The namespace of the service object.
__meta_kubernetes_service_annotation_<annotationname>: Each annotation from the service object.
__meta_kubernetes_service_annotationpresent_<annotationname>: "true" for each annotation of the service object.
__meta_kubernetes_service_cluster_ip: The cluster IP address of the service. (Does not apply to services of type ExternalName)
__meta_kubernetes_service_loadbalancer_ip: The IP address of the loadbalancer. (Applies to services of type LoadBalancer)
__meta_kubernetes_service_external_name: The DNS name of the service. (Applies to services of type ExternalName)
__meta_kubernetes_service_label_<labelname>: Each label from the service object, with any unsupported characters converted to an underscore.
__meta_kubernetes_service_labelpresent_<labelname>: true for each label of the service object, with any unsupported characters converted to an underscore.
__meta_kubernetes_service_name: The name of the service object.
__meta_kubernetes_service_port_name: Name of the service port for the target.
__meta_kubernetes_service_port_number: Number of the service port for the target.
__meta_kubernetes_service_port_protocol: Protocol of the service port for the target.
__meta_kubernetes_service_type: The type of the service.
pod
The pod role discovers all pods and exposes their containers as targets. For each declared port of a container, a single target is generated. If a container has no specified ports, a port-free target per container is created for manually adding a port via relabeling.

Available meta labels:

__meta_kubernetes_namespace: The namespace of the pod object.
__meta_kubernetes_pod_name: The name of the pod object.
__meta_kubernetes_pod_ip: The pod IP of the pod object.
__meta_kubernetes_pod_label_<labelname>: Each label from the pod object, with any unsupported characters converted to an underscore.
__meta_kubernetes_pod_labelpresent_<labelname>: true for each label from the pod object, with any unsupported characters converted to an underscore.
__meta_kubernetes_pod_annotation_<annotationname>: Each annotation from the pod object.
__meta_kubernetes_pod_annotationpresent_<annotationname>: true for each annotation from the pod object.
__meta_kubernetes_pod_container_init: true if the container is an InitContainer
__meta_kubernetes_pod_container_name: Name of the container the target address points to.
__meta_kubernetes_pod_container_id: ID of the container the target address points to. The ID is in the form <type>://<container_id>.
__meta_kubernetes_pod_container_image: The image the container is using.
__meta_kubernetes_pod_container_port_name: Name of the container port.
__meta_kubernetes_pod_container_port_number: Number of the container port.
__meta_kubernetes_pod_container_port_protocol: Protocol of the container port.
__meta_kubernetes_pod_ready: Set to true or false for the pod's ready state.
__meta_kubernetes_pod_phase: Set to Pending, Running, Succeeded, Failed or Unknown in the lifecycle.
__meta_kubernetes_pod_node_name: The name of the node the pod is scheduled onto.
__meta_kubernetes_pod_host_ip: The current host IP of the pod object.
__meta_kubernetes_pod_uid: The UID of the pod object.
__meta_kubernetes_pod_controller_kind: Object kind of the pod controller.
__meta_kubernetes_pod_controller_name: Name of the pod controller.
endpoints
The endpoints role discovers targets from listed endpoints of a service. For each endpoint address one target is discovered per port. If the endpoint is backed by a pod, all additional container ports of the pod, not bound to an endpoint port, are discovered as targets as well.

Note that the Endpoints API is deprecated in Kubernetes v1.33+, it is recommended to use EndpointSlices instead and switch to the endpointslice role below.

Available meta labels:

__meta_kubernetes_namespace: The namespace of the endpoints object.
__meta_kubernetes_endpoints_name: The names of the endpoints object.
__meta_kubernetes_endpoints_label_<labelname>: Each label from the endpoints object, with any unsupported characters converted to an underscore.
__meta_kubernetes_endpoints_labelpresent_<labelname>: true for each label from the endpoints object, with any unsupported characters converted to an underscore.
__meta_kubernetes_endpoints_annotation_<annotationname>: Each annotation from the endpoints object.
__meta_kubernetes_endpoints_annotationpresent_<annotationname>: true for each annotation from the endpoints object.
For all targets discovered directly from the endpoints list (those not additionally inferred from underlying pods), the following labels are attached:
__meta_kubernetes_endpoint_hostname: Hostname of the endpoint.
__meta_kubernetes_endpoint_node_name: Name of the node hosting the endpoint.
__meta_kubernetes_endpoint_ready: Set to true or false for the endpoint's ready state.
__meta_kubernetes_endpoint_port_name: Name of the endpoint port.
__meta_kubernetes_endpoint_port_protocol: Protocol of the endpoint port.
__meta_kubernetes_endpoint_address_target_kind: Kind of the endpoint address target.
__meta_kubernetes_endpoint_address_target_name: Name of the endpoint address target.
If the endpoints belong to a service, all labels of the role: service discovery are attached.
For all targets backed by a pod, all labels of the role: pod discovery are attached.
endpointslice
The endpointslice role discovers targets from existing endpointslices. For each endpoint address referenced in the endpointslice object one target is discovered. If the endpoint is backed by a pod, all additional container ports of the pod, not bound to an endpoint port, are discovered as targets as well.

The role requires the discovery.k8s.io/v1 API version (available since Kubernetes v1.21).

Available meta labels:

__meta_kubernetes_namespace: The namespace of the endpoints object.
__meta_kubernetes_endpointslice_name: The name of endpointslice object.
__meta_kubernetes_endpointslice_label_<labelname>: Each label from the endpointslice object, with any unsupported characters converted to an underscore.
__meta_kubernetes_endpointslice_labelpresent_<labelname>: true for each label from the endpointslice object, with any unsupported characters converted to an underscore.
__meta_kubernetes_endpointslice_annotation_<annotationname>: Each annotation from the endpointslice object.
__meta_kubernetes_endpointslice_annotationpresent_<annotationname>: true for each annotation from the endpointslice object.
For all targets discovered directly from the endpointslice list (those not additionally inferred from underlying pods), the following labels are attached:
__meta_kubernetes_endpointslice_address_target_kind: Kind of the referenced object.
__meta_kubernetes_endpointslice_address_target_name: Name of referenced object.
__meta_kubernetes_endpointslice_address_type: The ip protocol family of the address of the target.
__meta_kubernetes_endpointslice_endpoint_conditions_ready: Set to true or false for the referenced endpoint's ready state.
__meta_kubernetes_endpointslice_endpoint_conditions_serving: Set to true or false for the referenced endpoint's serving state.
__meta_kubernetes_endpointslice_endpoint_conditions_terminating: Set to true or false for the referenced endpoint's terminating state.
__meta_kubernetes_endpointslice_endpoint_topology_kubernetes_io_hostname: Name of the node hosting the referenced endpoint.
__meta_kubernetes_endpointslice_endpoint_topology_present_kubernetes_io_hostname: Flag that shows if the referenced object has a kubernetes.io/hostname annotation.
__meta_kubernetes_endpointslice_endpoint_hostname: Hostname of the referenced endpoint.
__meta_kubernetes_endpointslice_endpoint_node_name: Name of the Node hosting the referenced endpoint.
__meta_kubernetes_endpointslice_endpoint_zone: Zone the referenced endpoint exists in.
__meta_kubernetes_endpointslice_port: Port of the referenced endpoint.
__meta_kubernetes_endpointslice_port_name: Named port of the referenced endpoint.
__meta_kubernetes_endpointslice_port_protocol: Protocol of the referenced endpoint.
If the endpoints belong to a service, all labels of the role: service discovery are attached.
For all targets backed by a pod, all labels of the role: pod discovery are attached.
ingress
The ingress role discovers a target for each path of each ingress. This is generally useful for blackbox monitoring of an ingress. The address will be set to the host specified in the ingress spec.

The role requires the networking.k8s.io/v1 API version (available since Kubernetes v1.19).

Available meta labels:

__meta_kubernetes_namespace: The namespace of the ingress object.
__meta_kubernetes_ingress_name: The name of the ingress object.
__meta_kubernetes_ingress_label_<labelname>: Each label from the ingress object, with any unsupported characters converted to an underscore.
__meta_kubernetes_ingress_labelpresent_<labelname>: true for each label from the ingress object, with any unsupported characters converted to an underscore.
__meta_kubernetes_ingress_annotation_<annotationname>: Each annotation from the ingress object.
__meta_kubernetes_ingress_annotationpresent_<annotationname>: true for each annotation from the ingress object.
__meta_kubernetes_ingress_class_name: Class name from ingress spec, if present.
__meta_kubernetes_ingress_scheme: Protocol scheme of ingress, https if TLS config is set. Defaults to http.
__meta_kubernetes_ingress_path: Path from ingress spec. Defaults to /.
See below for the configuration options for Kubernetes discovery:

# The information to access the Kubernetes API.

# The API server addresses. If left empty, Prometheus is assumed to run inside
# of the cluster and will discover API servers automatically and use the pod's
# CA certificate and bearer token file at /var/run/secrets/kubernetes.io/serviceaccount/.
[ api_server: <host> ]

# The Kubernetes role of entities that should be discovered.
# One of endpoints, endpointslice, service, pod, node, or ingress.
role: <string>

# Optional path to a kubeconfig file.
# Note that api_server and kube_config are mutually exclusive.
[ kubeconfig_file: <filename> ]

# Optional namespace discovery. If omitted, all namespaces are used.
namespaces:
  own_namespace: <boolean>
  names:
    [ - <string> ]

# Optional label and field selectors to limit the discovery process to a subset of available resources.
# See https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/
# and https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ to learn more about the possible
# filters that can be used. The endpoints role supports pod, service and endpoints selectors.
# The pod role supports node selectors when configured with `attach_metadata: {node: true}`.
# Other roles only support selectors matching the role itself (e.g. node role can only contain node selectors).

# Note: When making decision about using field/label selector make sure that this
# is the best approach - it will prevent Prometheus from reusing single list/watch
# for all scrape configs. This might result in a bigger load on the Kubernetes API,
# because per each selector combination there will be additional LIST/WATCH. On the other hand,
# if you just want to monitor small subset of pods in large cluster it's recommended to use selectors.
# Decision, if selectors should be used or not depends on the particular situation.
[ selectors:
  [ - role: <string>
    [ label: <string> ]
    [ field: <string> ] ]]

# Optional metadata to attach to discovered targets. If omitted, no additional metadata is attached.
attach_metadata:
# Attaches node metadata to discovered targets. Valid for roles: pod, endpoints, endpointslice.
# When set to true, Prometheus must have permissions to get Nodes.
  [ node: <boolean> | default = false ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
See this example Prometheus configuration file for a detailed example of configuring Prometheus for Kubernetes.

You may wish to check out the 3rd party Prometheus Operator, which automates the Prometheus setup on top of Kubernetes.

<kuma_sd_config>
Kuma SD configurations allow retrieving scrape target from the Kuma control plane.

This SD discovers "monitoring assignments" based on Kuma Dataplane Proxies, via the MADS v1 (Monitoring Assignment Discovery Service) xDS API, and will create a target for each proxy inside a Prometheus-enabled mesh.

The following meta labels are available for each target:

__meta_kuma_mesh: the name of the proxy's Mesh
__meta_kuma_dataplane: the name of the proxy
__meta_kuma_service: the name of the proxy's associated Service
__meta_kuma_label_<tagname>: each tag of the proxy
See below for the configuration options for Kuma MonitoringAssignment discovery:

# Address of the Kuma Control Plane's MADS xDS server.
server: <string>

# Client id is used by Kuma Control Plane to compute Monitoring Assignment for specific Prometheus backend.
# This is useful when migrating between multiple Prometheus backends, or having separate backend for each Mesh.
# When not specified, system hostname/fqdn will be used if available, if not `prometheus` will be used.
[ client_id: <string> ]

# The time to wait between polling update requests.
[ refresh_interval: <duration> | default = 30s ]

# The time after which the monitoring assignments are refreshed.
[ fetch_timeout: <duration> | default = 2m ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
The relabeling phase is the preferred and more powerful way to filter proxies and user-defined tags.

<lightsail_sd_config>
Lightsail SD configurations allow retrieving scrape targets from AWS Lightsail instances. The private IP address is used by default, but may be changed to the public IP address with relabeling.

The following meta labels are available on targets during relabeling:

__meta_lightsail_availability_zone: the availability zone in which the instance is running
__meta_lightsail_blueprint_id: the Lightsail blueprint ID
__meta_lightsail_bundle_id: the Lightsail bundle ID
__meta_lightsail_instance_name: the name of the Lightsail instance
__meta_lightsail_instance_state: the state of the Lightsail instance
__meta_lightsail_instance_support_code: the support code of the Lightsail instance
__meta_lightsail_ipv6_addresses: comma separated list of IPv6 addresses assigned to the instance's network interfaces, if present
__meta_lightsail_private_ip: the private IP address of the instance
__meta_lightsail_public_ip: the public IP address of the instance, if available
__meta_lightsail_region: the region of the instance
__meta_lightsail_tag_<tagkey>: each tag value of the instance
See below for the configuration options for Lightsail discovery:

# The information to access the Lightsail API.

# The AWS region. If blank, the region from the instance metadata is used.
[ region: <string> ]

# Custom endpoint to be used.
[ endpoint: <string> ]

# The AWS API keys. If blank, the environment variables `AWS_ACCESS_KEY_ID`
# and `AWS_SECRET_ACCESS_KEY` are used.
[ access_key: <string> ]
[ secret_key: <secret> ]
# Named AWS profile used to connect to the API.
[ profile: <string> ]

# AWS Role ARN, an alternative to using AWS API keys.
[ role_arn: <string> ]

# Refresh interval to re-read the instance list.
[ refresh_interval: <duration> | default = 60s ]

# The port to scrape metrics from. If using the public IP address, this must
# instead be specified in the relabeling rule.
[ port: <int> | default = 80 ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<linode_sd_config>
Linode SD configurations allow retrieving scrape targets from Linode's Linode APIv4. This service discovery uses the public IPv4 address by default, by that can be changed with relabeling, as demonstrated in the Prometheus linode-sd configuration file.

Linode APIv4 Token must be created with scopes: linodes:read_only, ips:read_only, and events:read_only.

The following meta labels are available on targets during relabeling:

__meta_linode_instance_id: the id of the linode instance
__meta_linode_instance_label: the label of the linode instance
__meta_linode_image: the slug of the linode instance's image
__meta_linode_private_ipv4: the private IPv4 of the linode instance
__meta_linode_public_ipv4: the public IPv4 of the linode instance
__meta_linode_public_ipv6: the public IPv6 of the linode instance
__meta_linode_private_ipv4_rdns: the reverse DNS for the first private IPv4 of the linode instance
__meta_linode_public_ipv4_rdns: the reverse DNS for the first public IPv4 of the linode instance
__meta_linode_public_ipv6_rdns: the reverse DNS for the first public IPv6 of the linode instance
__meta_linode_region: the region of the linode instance
__meta_linode_type: the type of the linode instance
__meta_linode_status: the status of the linode instance
__meta_linode_tags: a list of tags of the linode instance joined by the tag separator
__meta_linode_group: the display group a linode instance is a member of
__meta_linode_gpus: the number of GPU's of the linode instance
__meta_linode_hypervisor: the virtualization software powering the linode instance
__meta_linode_backups: the backup service status of the linode instance
__meta_linode_specs_disk_bytes: the amount of storage space the linode instance has access to
__meta_linode_specs_memory_bytes: the amount of RAM the linode instance has access to
__meta_linode_specs_vcpus: the number of VCPUS this linode has access to
__meta_linode_specs_transfer_bytes: the amount of network transfer the linode instance is allotted each month
__meta_linode_extra_ips: a list of all extra IPv4 addresses assigned to the linode instance joined by the tag separator
__meta_linode_ipv6_ranges: a list of IPv6 ranges with mask assigned to the linode instance joined by the tag separator

# Optional region to filter on.
[ region: <string> ]

# The port to scrape metrics from.
[ port: <int> | default = 80 ]

# The string by which Linode Instance tags are joined into the tag label.
[ tag_separator: <string> | default = , ]

# The time after which the linode instances are refreshed.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<marathon_sd_config>
Marathon SD configurations allow retrieving scrape targets using the Marathon REST API. Prometheus will periodically check the REST endpoint for currently running tasks and create a target group for every app that has at least one healthy task.

The following meta labels are available on targets during relabeling:

__meta_marathon_app: the name of the app (with slashes replaced by dashes)
__meta_marathon_image: the name of the Docker image used (if available)
__meta_marathon_task: the ID of the Mesos task
__meta_marathon_app_label_<labelname>: any Marathon labels attached to the app, with any unsupported characters converted to an underscore
__meta_marathon_port_definition_label_<labelname>: the port definition labels, with any unsupported characters converted to an underscore
__meta_marathon_port_mapping_label_<labelname>: the port mapping labels, with any unsupported characters converted to an underscore
__meta_marathon_port_index: the port index number (e.g. 1 for PORT1)
See below for the configuration options for Marathon discovery:

# List of URLs to be used to contact Marathon servers.
# You need to provide at least one server URL.
servers:
  - <string>

# Polling interval
[ refresh_interval: <duration> | default = 30s ]

# Optional authentication information for token-based authentication
# https://docs.mesosphere.com/1.11/security/ent/iam-api/#passing-an-authentication-token
# It is mutually exclusive with `auth_token_file` and other authentication mechanisms.
[ auth_token: <secret> ]

# Optional authentication information for token-based authentication
# https://docs.mesosphere.com/1.11/security/ent/iam-api/#passing-an-authentication-token
# It is mutually exclusive with `auth_token` and other authentication mechanisms.
[ auth_token_file: <filename> ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
By default every app listed in Marathon will be scraped by Prometheus. If not all of your services provide Prometheus metrics, you can use a Marathon label and Prometheus relabeling to control which instances will actually be scraped. See the Prometheus marathon-sd configuration file for a practical example on how to set up your Marathon app and your Prometheus configuration.

By default, all apps will show up as a single job in Prometheus (the one specified in the configuration file), which can also be changed using relabeling.

<nerve_sd_config>
Nerve SD configurations allow retrieving scrape targets from [AirBnB's Nerve] (https://github.com/airbnb/nerve) which are stored in Zookeeper.

The following meta labels are available on targets during relabeling:

__meta_nerve_path: the full path to the endpoint node in Zookeeper
__meta_nerve_endpoint_host: the host of the endpoint
__meta_nerve_endpoint_port: the port of the endpoint
__meta_nerve_endpoint_name: the name of the endpoint
# The Zookeeper servers.
servers:
  - <host>
# Paths can point to a single service, or the root of a tree of services.
paths:
  - <string>
[ timeout: <duration> | default = 10s ]
<nomad_sd_config>
Nomad SD configurations allow retrieving scrape targets from Nomad's Service API.

The following meta labels are available on targets during relabeling:

__meta_nomad_address: the service address of the target
__meta_nomad_dc: the datacenter name for the target
__meta_nomad_namespace: the namespace of the target
__meta_nomad_node_id: the node name defined for the target
__meta_nomad_service: the name of the service the target belongs to
__meta_nomad_service_address: the service address of the target
__meta_nomad_service_id: the service ID of the target
__meta_nomad_service_port: the service port of the target
__meta_nomad_tags: the list of tags of the target joined by the tag separator
# The information to access the Nomad API. It is to be defined
# as the Nomad documentation requires.
[ allow_stale: <boolean> | default = true ]
[ namespace: <string> | default = default ]
[ refresh_interval: <duration> | default = 60s ]
[ region: <string> | default = global ]
# The URL to connect to the API.
[ server: <string> ]
[ tag_separator: <string> | default = ,]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<serverset_sd_config>
Serverset SD configurations allow retrieving scrape targets from [Serversets] (https://github.com/twitter/finagle/tree/develop/finagle-serversets) which are stored in Zookeeper. Serversets are commonly used by Finagle and Aurora.

The following meta labels are available on targets during relabeling:

__meta_serverset_path: the full path to the serverset member node in Zookeeper
__meta_serverset_endpoint_host: the host of the default endpoint
__meta_serverset_endpoint_port: the port of the default endpoint
__meta_serverset_endpoint_host_<endpoint>: the host of the given endpoint
__meta_serverset_endpoint_port_<endpoint>: the port of the given endpoint
__meta_serverset_shard: the shard number of the member
__meta_serverset_status: the status of the member
# The Zookeeper servers.
servers:
  - <host>
# Paths can point to a single serverset, or the root of a tree of serversets.
paths:
  - <string>
[ timeout: <duration> | default = 10s ]
Serverset data must be in the JSON format, the Thrift format is not currently supported.

<stackit_sd_config>
STACKIT SD configurations allow retrieving scrape targets from various APIs.

The following meta labels are available on targets during relabeling:

__meta_stackit_availability_zone: The availability zone of the server.
__meta_stackit_label_<labelname>: Each server label, with unsupported characters replaced by underscores.
__meta_stackit_labelpresent_<labelname>: "true" for each label of the server, with unsupported characters replaced by underscores.
__meta_stackit_private_ipv4_<networkname>: the private ipv4 address of the server within a given network
__meta_stackit_public_ipv4: the public ipv4 address of the server
__meta_stackit_id: The ID of the target.
__meta_stackit_type: The type or brand of the target.
__meta_stackit_name: The server name.
__meta_stackit_status: The current status of the server.
__meta_stackit_power_status: The power status of the server.
See below for the configuration options for STACKIT discovery:

# The STACKIT project 
project: <string>

# STACKIT region to use. No automatic discovery of the region is done.
[ region : <string> | default = "eu01" ]

# Custom API endpoint to be used. Format scheme://host:port
[ endpoint : <string>  ]

# The port to scrape metrics from.
[ port: <int> | default = 80 ]

# Raw private key string used for authenticating a service account
[ private_key: <string> ]

# Path to a file containing the raw private key string
[ private_key_path: <string> ]

# Full JSON-formatted service account key used for authentication
[ service_account_key: <string> ]

# Path to a file containing the JSON-formatted service account key
[ service_account_key_path: <string> ]

# Path to a file containing STACKIT credentials.
[ credentials_file_path: <string> ]

# The time after which the servers are refreshed.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
A Service Account Token can be set through http_config.

stackit_sd_config:
- authorization:
    credentials: <token>
<triton_sd_config>
Triton SD configurations allow retrieving scrape targets from Container Monitor discovery endpoints.

One of the following <triton_role> types can be configured to discover targets:

container
The container role discovers one target per "virtual machine" owned by the account. These are SmartOS zones or lx/KVM/bhyve branded zones.

The following meta labels are available on targets during relabeling:

__meta_triton_groups: the list of groups belonging to the target joined by a comma separator
__meta_triton_machine_alias: the alias of the target container
__meta_triton_machine_brand: the brand of the target container
__meta_triton_machine_id: the UUID of the target container
__meta_triton_machine_image: the target container's image type
__meta_triton_server_id: the server UUID the target container is running on
cn
The cn role discovers one target for per compute node (also known as "server" or "global zone") making up the Triton infrastructure. The account must be a Triton operator and is currently required to own at least one container.

The following meta labels are available on targets during relabeling:

__meta_triton_machine_alias: the hostname of the target (requires triton-cmon 1.7.0 or newer)
__meta_triton_machine_id: the UUID of the target
See below for the configuration options for Triton discovery:

# The information to access the Triton discovery API.

# The account to use for discovering new targets.
account: <string>

# The type of targets to discover, can be set to:
# * "container" to discover virtual machines (SmartOS zones, lx/KVM/bhyve branded zones) running on Triton
# * "cn" to discover compute nodes (servers/global zones) making up the Triton infrastructure
[ role : <string> | default = "container" ]

# The DNS suffix which should be applied to target.
dns_suffix: <string>

# The Triton discovery endpoint (e.g. 'cmon.us-east-3b.triton.zone'). This is
# often the same value as dns_suffix.
endpoint: <string>

# A list of groups for which targets are retrieved, only supported when `role` == `container`.
# If omitted all containers owned by the requesting account are scraped.
groups:
  [ - <string> ... ]

# The port to use for discovery and metric scraping.
[ port: <int> | default = 9163 ]

# The interval which should be used for refreshing targets.
[ refresh_interval: <duration> | default = 60s ]

# The Triton discovery API version.
[ version: <int> | default = 1 ]

# TLS configuration.
tls_config:
  [ <tls_config> ]
<eureka_sd_config>
Eureka SD configurations allow retrieving scrape targets using the Eureka REST API. Prometheus will periodically check the REST endpoint and create a target for every app instance.

The following meta labels are available on targets during relabeling:

__meta_eureka_app_name: the name of the app
__meta_eureka_app_instance_id: the ID of the app instance
__meta_eureka_app_instance_hostname: the hostname of the instance
__meta_eureka_app_instance_homepage_url: the homepage url of the app instance
__meta_eureka_app_instance_statuspage_url: the status page url of the app instance
__meta_eureka_app_instance_healthcheck_url: the health check url of the app instance
__meta_eureka_app_instance_ip_addr: the IP address of the app instance
__meta_eureka_app_instance_vip_address: the VIP address of the app instance
__meta_eureka_app_instance_secure_vip_address: the secure VIP address of the app instance
__meta_eureka_app_instance_status: the status of the app instance
__meta_eureka_app_instance_port: the port of the app instance
__meta_eureka_app_instance_port_enabled: the port enabled of the app instance
__meta_eureka_app_instance_secure_port: the secure port address of the app instance
__meta_eureka_app_instance_secure_port_enabled: the secure port of the app instance
__meta_eureka_app_instance_country_id: the country ID of the app instance
__meta_eureka_app_instance_metadata_<metadataname>: app instance metadata
__meta_eureka_app_instance_datacenterinfo_name: the datacenter name of the app instance
__meta_eureka_app_instance_datacenterinfo_<metadataname>: the datacenter metadata
See below for the configuration options for Eureka discovery:

# The URL to connect to the Eureka server.
server: <string>

# Refresh interval to re-read the app instance list.
[ refresh_interval: <duration> | default = 30s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
See the Prometheus eureka-sd configuration file for a practical example on how to set up your Eureka app and your Prometheus configuration.

<scaleway_sd_config>
Scaleway SD configurations allow retrieving scrape targets from Scaleway instances and baremetal services.

The following meta labels are available on targets during relabeling:

Instance role
__meta_scaleway_instance_boot_type: the boot type of the server
__meta_scaleway_instance_hostname: the hostname of the server
__meta_scaleway_instance_id: the ID of the server
__meta_scaleway_instance_image_arch: the arch of the server image
__meta_scaleway_instance_image_id: the ID of the server image
__meta_scaleway_instance_image_name: the name of the server image
__meta_scaleway_instance_location_cluster_id: the cluster ID of the server location
__meta_scaleway_instance_location_hypervisor_id: the hypervisor ID of the server location
__meta_scaleway_instance_location_node_id: the node ID of the server location
__meta_scaleway_instance_name: name of the server
__meta_scaleway_instance_organization_id: the organization of the server
__meta_scaleway_instance_private_ipv4: the private IPv4 address of the server
__meta_scaleway_instance_project_id: project id of the server
__meta_scaleway_instance_public_ipv4: the public IPv4 address of the server
__meta_scaleway_instance_public_ipv6: the public IPv6 address of the server
__meta_scaleway_instance_public_ipv4_addresses: the public IPv4 addresses of the server
__meta_scaleway_instance_public_ipv6_addresses: the public IPv6 addresses of the server
__meta_scaleway_instance_region: the region of the server
__meta_scaleway_instance_security_group_id: the ID of the security group of the server
__meta_scaleway_instance_security_group_name: the name of the security group of the server
__meta_scaleway_instance_status: status of the server
__meta_scaleway_instance_tags: the list of tags of the server joined by the tag separator
__meta_scaleway_instance_type: commercial type of the server
__meta_scaleway_instance_zone: the zone of the server (ex: fr-par-1, complete list here)
This role uses the first address it finds in the following order: private IPv4, public IPv4, public IPv6. This can be changed with relabeling, as demonstrated in the Prometheus scaleway-sd configuration file. Should an instance have no address before relabeling, it will not be added to the target list and you will not be able to relabel it.

Baremetal role
__meta_scaleway_baremetal_id: the ID of the server
__meta_scaleway_baremetal_public_ipv4: the public IPv4 address of the server
__meta_scaleway_baremetal_public_ipv6: the public IPv6 address of the server
__meta_scaleway_baremetal_name: the name of the server
__meta_scaleway_baremetal_os_name: the name of the operating system of the server
__meta_scaleway_baremetal_os_version: the version of the operating system of the server
__meta_scaleway_baremetal_project_id: the project ID of the server
__meta_scaleway_baremetal_status: the status of the server
__meta_scaleway_baremetal_tags: the list of tags of the server joined by the tag separator
__meta_scaleway_baremetal_type: the commercial type of the server
__meta_scaleway_baremetal_zone: the zone of the server (ex: fr-par-1, complete list here)
This role uses the public IPv4 address by default. This can be changed with relabeling, as demonstrated in the Prometheus scaleway-sd configuration file.

See below for the configuration options for Scaleway discovery:

# Access key to use. https://console.scaleway.com/project/credentials
access_key: <string>

# Secret key to use when listing targets. https://console.scaleway.com/project/credentials
# It is mutually exclusive with `secret_key_file`.
[ secret_key: <secret> ]

# Sets the secret key with the credentials read from the configured file.
# It is mutually exclusive with `secret_key`.
[ secret_key_file: <filename> ]

# Project ID of the targets.
project_id: <string>

# Role of the targets to retrieve. Must be `instance` or `baremetal`.
role: <string>

# The port to scrape metrics from.
[ port: <int> | default = 80 ]

# API URL to use when doing the server listing requests.
[ api_url: <string> | default = "https://api.scaleway.com" ]

# Zone is the availability zone of your targets (e.g. fr-par-1).
[ zone: <string> | default = fr-par-1 ]

# NameFilter specify a name filter (works as a LIKE) to apply on the server listing request.
[ name_filter: <string> ]

# TagsFilter specify a tag filter (a server needs to have all defined tags to be listed) to apply on the server listing request.
tags_filter:
[ - <string> ]

# Refresh interval to re-read the targets list.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<uyuni_sd_config>
Uyuni SD configurations allow retrieving scrape targets from managed systems via Uyuni API.

The following meta labels are available on targets during relabeling:

__meta_uyuni_endpoint_name: the name of the application endpoint
__meta_uyuni_exporter: the exporter exposing metrics for the target
__meta_uyuni_groups: the system groups of the target
__meta_uyuni_metrics_path: metrics path for the target
__meta_uyuni_minion_hostname: hostname of the Uyuni client
__meta_uyuni_primary_fqdn: primary FQDN of the Uyuni client
__meta_uyuni_proxy_module: the module name if Exporter Exporter proxy is configured for the target
__meta_uyuni_scheme: the protocol scheme used for requests
__meta_uyuni_system_id: the system ID of the client
See below for the configuration options for Uyuni discovery:

# The URL to connect to the Uyuni server.
server: <string>

# Credentials are used to authenticate the requests to Uyuni API.
username: <string>
password: <secret>

# The entitlement string to filter eligible systems.
[ entitlement: <string> | default = monitoring_entitled ]

# The string by which Uyuni group names are joined into the groups label.
[ separator: <string> | default = , ]

# Refresh interval to re-read the managed targets list.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
See the Prometheus uyuni-sd configuration file for a practical example on how to set up Uyuni Prometheus configuration.

<vultr_sd_config>
Vultr SD configurations allow retrieving scrape targets from Vultr.

This service discovery uses the main IPv4 address by default, which that be changed with relabeling, as demonstrated in the Prometheus vultr-sd configuration file.

The following meta labels are available on targets during relabeling:

__meta_vultr_instance_id : A unique ID for the vultr Instance.
__meta_vultr_instance_label : The user-supplied label for this instance.
__meta_vultr_instance_os : The Operating System name.
__meta_vultr_instance_os_id : The Operating System id used by this instance.
__meta_vultr_instance_region : The Region id where the Instance is located.
__meta_vultr_instance_plan : A unique ID for the Plan.
__meta_vultr_instance_main_ip : The main IPv4 address.
__meta_vultr_instance_internal_ip : The private IP address.
__meta_vultr_instance_main_ipv6 : The main IPv6 address.
__meta_vultr_instance_features : List of features that are available to the instance.
__meta_vultr_instance_tags : List of tags associated with the instance.
__meta_vultr_instance_hostname : The hostname for this instance.
__meta_vultr_instance_server_status : The server health status.
__meta_vultr_instance_vcpu_count : Number of vCPUs.
__meta_vultr_instance_ram_mb : The amount of RAM in MB.
__meta_vultr_instance_disk_gb : The size of the disk in GB.
__meta_vultr_instance_allowed_bandwidth_gb : Monthly bandwidth quota in GB.
# The port to scrape metrics from.
[ port: <int> | default = 80 ]

# The time after which the instances are refreshed.
[ refresh_interval: <duration> | default = 60s ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
<static_config>
A static_config allows specifying a list of targets and a common label set for them. It is the canonical way to specify static targets in a scrape configuration.

# The targets specified by the static config.
targets:
  [ - '<host>' ]

# Labels assigned to all metrics scraped from the targets.
labels:
  [ <labelname>: <labelvalue> ... ]
<relabel_config>
Relabeling is a powerful tool to dynamically rewrite the label set of a target before it gets scraped. Multiple relabeling steps can be configured per scrape configuration. They are applied to the label set of each target in order of their appearance in the configuration file.

Initially, aside from the configured per-target labels, a target's job label is set to the job_name value of the respective scrape configuration. The __address__ label is set to the <host>:<port> address of the target. After relabeling, the instance label is set to the value of __address__ by default if it was not set during relabeling.

The __scheme__ and __metrics_path__ labels are set to the scheme and metrics path of the target respectively, as specified in scrape_config.

The __param_<name> label is set to the value of the first passed URL parameter called <name>, as defined in scrape_config.

The __scrape_interval__ and __scrape_timeout__ labels are set to the target's interval and timeout, as specified in scrape_config.

Additional labels prefixed with __meta_ may be available during the relabeling phase. They are set by the service discovery mechanism that provided the target and vary between mechanisms.

Labels starting with __ will be removed from the label set after target relabeling is completed.

If a relabeling step needs to store a label value only temporarily (as the input to a subsequent relabeling step), use the __tmp label name prefix. This prefix is guaranteed to never be used by Prometheus itself.

# The source_labels tells the rule what labels to fetch from the series. Any
# labels which do not exist get a blank value ("").  Their content is concatenated
# using the configured separator and matched against the configured regular expression
# for the replace, keep, and drop actions.
[ source_labels: '[' <labelname> [, ...] ']' ]

# Separator placed between concatenated source label values.
[ separator: <string> | default = ; ]

# Label to which the resulting value is written in a replace action.
# It is mandatory for replace actions. Regex capture groups are available.
[ target_label: <labelname> ]

# Regular expression against which the extracted value is matched.
[ regex: <regex> | default = (.*) ]

# Modulus to take of the hash of the source label values.
[ modulus: <int> ]

# Replacement value against which a regex replace is performed if the
# regular expression matches. Regex capture groups are available.
[ replacement: <string> | default = $1 ]

# Action to perform based on regex matching.
[ action: <relabel_action> | default = replace ]
<regex> is any valid RE2 regular expression. It is required for the replace, keep, drop, labelmap,labeldrop and labelkeep actions. The regex is anchored on both ends. To un-anchor the regex, use .*<regex>.*.

<relabel_action> determines the relabeling action to take:

replace: Match regex against the concatenated source_labels. Then, set target_label to replacement, with match group references (${1}, ${2}, ...) in replacement substituted by their value. If regex does not match, no replacement takes place.
lowercase: Maps the concatenated source_labels to their lower case.
uppercase: Maps the concatenated source_labels to their upper case.
keep: Drop targets for which regex does not match the concatenated source_labels.
drop: Drop targets for which regex matches the concatenated source_labels.
keepequal: Drop targets for which the concatenated source_labels do not match target_label.
dropequal: Drop targets for which the concatenated source_labels do match target_label.
hashmod: Set target_label to the modulus of a hash of the concatenated source_labels.
labelmap: Match regex against all source label names, not just those specified in source_labels. Then copy the values of the matching labels to label names given by replacement with match group references (${1}, ${2}, ...) in replacement substituted by their value.
labeldrop: Match regex against all label names. Any label that matches will be removed from the set of labels.
labelkeep: Match regex against all label names. Any label that does not match will be removed from the set of labels.
Care must be taken with labeldrop and labelkeep to ensure that metrics are still uniquely labeled once the labels are removed.

<metric_relabel_configs>
Metric relabeling is applied to samples as the last step before ingestion. It has the same configuration format and actions as target relabeling. Metric relabeling does not apply to automatically generated timeseries such as up.

One use for this is to exclude time series that are too expensive to ingest.

<alert_relabel_configs>
Alert relabeling is applied to alerts before they are sent to the Alertmanager. It has the same configuration format and actions as target relabeling. Alert relabeling is applied after external labels.

One use for this is ensuring a HA pair of Prometheus servers with different external labels send identical alerts.

<alertmanager_config>
An alertmanager_config section specifies Alertmanager instances the Prometheus server sends alerts to. It also provides parameters to configure how to communicate with these Alertmanagers.

Alertmanagers may be statically configured via the static_configs parameter or dynamically discovered using one of the supported service-discovery mechanisms.

Additionally, relabel_configs allow selecting Alertmanagers from discovered entities and provide advanced modifications to the used API path, which is exposed through the __alerts_path__ label.

# Per-target Alertmanager timeout when pushing alerts.
[ timeout: <duration> | default = 10s ]

# The api version of Alertmanager.
[ api_version: <string> | default = v2 ]

# Prefix for the HTTP path alerts are pushed to.
[ path_prefix: <path> | default = / ]

# Configures the protocol scheme used for requests.
[ scheme: <scheme> | default = http ]

# Optionally configures AWS's Signature Verification 4 signing process to sign requests.
# Cannot be set at the same time as basic_auth, authorization, oauth2, azuread or google_iam.
# To use the default credentials from the AWS SDK, use `sigv4: {}`.
sigv4:
  # The AWS region. If blank, the region from the default credentials chain
  # is used.
  [ region: <string> ]

  # The AWS API keys. If blank, the environment variables `AWS_ACCESS_KEY_ID`
  # and `AWS_SECRET_ACCESS_KEY` are used.
  [ access_key: <string> ]
  [ secret_key: <secret> ]

  # Named AWS profile used to authenticate.
  [ profile: <string> ]

  # AWS Role ARN, an alternative to using AWS API keys.
  [ role_arn: <string> ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]

# List of Azure service discovery configurations.
azure_sd_configs:
  [ - <azure_sd_config> ... ]

# List of Consul service discovery configurations.
consul_sd_configs:
  [ - <consul_sd_config> ... ]

# List of DNS service discovery configurations.
dns_sd_configs:
  [ - <dns_sd_config> ... ]

# List of EC2 service discovery configurations.
ec2_sd_configs:
  [ - <ec2_sd_config> ... ]

# List of Eureka service discovery configurations.
eureka_sd_configs:
  [ - <eureka_sd_config> ... ]

# List of file service discovery configurations.
file_sd_configs:
  [ - <file_sd_config> ... ]

# List of DigitalOcean service discovery configurations.
digitalocean_sd_configs:
  [ - <digitalocean_sd_config> ... ]

# List of Docker service discovery configurations.
docker_sd_configs:
  [ - <docker_sd_config> ... ]

# List of Docker Swarm service discovery configurations.
dockerswarm_sd_configs:
  [ - <dockerswarm_sd_config> ... ]

# List of GCE service discovery configurations.
gce_sd_configs:
  [ - <gce_sd_config> ... ]

# List of Hetzner service discovery configurations.
hetzner_sd_configs:
  [ - <hetzner_sd_config> ... ]

# List of HTTP service discovery configurations.
http_sd_configs:
  [ - <http_sd_config> ... ]

 # List of IONOS service discovery configurations.
ionos_sd_configs:
  [ - <ionos_sd_config> ... ]

# List of Kubernetes service discovery configurations.
kubernetes_sd_configs:
  [ - <kubernetes_sd_config> ... ]

# List of Lightsail service discovery configurations.
lightsail_sd_configs:
  [ - <lightsail_sd_config> ... ]

# List of Linode service discovery configurations.
linode_sd_configs:
  [ - <linode_sd_config> ... ]

# List of Marathon service discovery configurations.
marathon_sd_configs:
  [ - <marathon_sd_config> ... ]

# List of AirBnB's Nerve service discovery configurations.
nerve_sd_configs:
  [ - <nerve_sd_config> ... ]

# List of Nomad service discovery configurations.
nomad_sd_configs:
  [ - <nomad_sd_config> ... ]

# List of OpenStack service discovery configurations.
openstack_sd_configs:
  [ - <openstack_sd_config> ... ]

# List of OVHcloud service discovery configurations.
ovhcloud_sd_configs:
  [ - <ovhcloud_sd_config> ... ]

# List of PuppetDB service discovery configurations.
puppetdb_sd_configs:
  [ - <puppetdb_sd_config> ... ]

# List of Scaleway service discovery configurations.
scaleway_sd_configs:
  [ - <scaleway_sd_config> ... ]

# List of Zookeeper Serverset service discovery configurations.
serverset_sd_configs:
  [ - <serverset_sd_config> ... ]

# List of STACKIT service discovery configurations.
stackit_sd_configs:
  [ - <stackit_sd_config> ... ]

# List of Triton service discovery configurations.
triton_sd_configs:
  [ - <triton_sd_config> ... ]

# List of Uyuni service discovery configurations.
uyuni_sd_configs:
  [ - <uyuni_sd_config> ... ]

# List of Vultr service discovery configurations.
vultr_sd_configs:
  [ - <vultr_sd_config> ... ]

# List of labeled statically configured Alertmanagers.
static_configs:
  [ - <static_config> ... ]

# List of Alertmanager relabel configurations.
relabel_configs:
  [ - <relabel_config> ... ]

# List of alert relabel configurations.
alert_relabel_configs:
  [ - <relabel_config> ... ]
<remote_write>
write_relabel_configs is relabeling applied to samples before sending them to the remote endpoint. Write relabeling is applied after external labels. This could be used to limit which samples are sent.

There is a small demo of how to use this functionality.

# The URL of the endpoint to send samples to.
url: <string>

# protobuf message to use when writing to the remote write endpoint.
#
# * The `prometheus.WriteRequest` represents the message introduced in Remote Write 1.0, which
# will be deprecated eventually.
# * The `io.prometheus.write.v2.Request` was introduced in Remote Write 2.0 and replaces the former,
# by improving efficiency and sending metadata, created timestamp and native histograms by default.
#
# Before changing this value, consult with your remote storage provider (or test) what message it supports.
# Read more on https://prometheus.io/docs/specs/remote_write_spec_2_0/#io-prometheus-write-v2-request
[ protobuf_message: <prometheus.WriteRequest | io.prometheus.write.v2.Request> | default = prometheus.WriteRequest ]

# Timeout for requests to the remote write endpoint.
[ remote_timeout: <duration> | default = 30s ]

# Custom HTTP headers to be sent along with each remote write request.
# Be aware that headers that are set by Prometheus itself can't be overwritten.
headers:
  [ <string>: <string> ... ]

# List of remote write relabel configurations.
write_relabel_configs:
  [ - <relabel_config> ... ]

# Name of the remote write config, which if specified must be unique among remote write configs.
# The name will be used in metrics and logging in place of a generated value to help users distinguish between
# remote write configs.
[ name: <string> ]

# Enables sending of exemplars over remote write. Note that exemplar storage itself must be enabled for exemplars to be scraped in the first place.
[ send_exemplars: <boolean> | default = false ]

# Enables sending of native histograms, also known as sparse histograms, over remote write.
# For the `io.prometheus.write.v2.Request` message, this option is noop (always true).
[ send_native_histograms: <boolean> | default = false ]

# When enabled, remote-write will resolve the URL host name via DNS, choose one of the IP addresses at random, and connect to it.
# When disabled, remote-write relies on Go's standard behavior, which is to try to connect to each address in turn.
# The connection timeout applies to the whole operation, i.e. in the latter case it is spread over all attempt.
# This is an experimental feature, and its behavior might still change, or even get removed.
[ round_robin_dns: <boolean> | default = false ]

# Optionally configures AWS's Signature Verification 4 signing process to
# sign requests. Cannot be set at the same time as basic_auth, authorization, oauth2, or azuread.
# To use the default credentials from the AWS SDK, use `sigv4: {}`.
sigv4:
  # The AWS region. If blank, the region from the default credentials chain
  # is used.
  [ region: <string> ]

  # The AWS API keys. If blank, the environment variables `AWS_ACCESS_KEY_ID`
  # and `AWS_SECRET_ACCESS_KEY` are used.
  [ access_key: <string> ]
  [ secret_key: <secret> ]

  # Named AWS profile used to authenticate.
  [ profile: <string> ]

  # AWS Role ARN, an alternative to using AWS API keys.
  [ role_arn: <string> ]

# Optional AzureAD configuration.
# Cannot be used at the same time as basic_auth, authorization, oauth2, sigv4 or google_iam.
azuread:
  # The Azure Cloud. Options are 'AzurePublic', 'AzureChina', or 'AzureGovernment'.
  [ cloud: <string> | default = AzurePublic ]

  # Azure Managed Identity.  Leave 'client_id' blank to use the default managed identity.
  [ managed_identity:
      [ client_id: <string> ] ]

  # Azure OAuth.
  [ oauth:
      [ client_id: <string> ]
      [ client_secret: <string> ]
      [ tenant_id: <string> ] ]

  # Azure SDK auth.
  # See https://learn.microsoft.com/en-us/azure/developer/go/azure-sdk-authentication
  [ sdk:
      [ tenant_id: <string> ] ]

# WARNING: Remote write is NOT SUPPORTED by Google Cloud. This configuration is reserved for future use.
# Optional Google Cloud Monitoring configuration.
# Cannot be used at the same time as basic_auth, authorization, oauth2, sigv4 or azuread.
# To use the default credentials from the Google Cloud SDK, use `google_iam: {}`.
google_iam:
  # Service account key with monitoring write permissions.
  credentials_file: <file_name>

# Configures the queue used to write to remote storage.
queue_config:
  # Number of samples to buffer per shard before we block reading of more
  # samples from the WAL. It is recommended to have enough capacity in each
  # shard to buffer several requests to keep throughput up while processing
  # occasional slow remote requests.
  [ capacity: <int> | default = 10000 ]
  # Maximum number of shards, i.e. amount of concurrency.
  [ max_shards: <int> | default = 50 ]
  # Minimum number of shards, i.e. amount of concurrency.
  [ min_shards: <int> | default = 1 ]
  # Maximum number of samples per send.
  [ max_samples_per_send: <int> | default = 2000]
  # Maximum time a sample will wait for a send. The sample might wait less
  # if the buffer is full. Further time might pass due to potential retries.
  [ batch_send_deadline: <duration> | default = 5s ]
  # Initial retry delay. Gets doubled for every retry.
  [ min_backoff: <duration> | default = 30ms ]
  # Maximum retry delay.
  [ max_backoff: <duration> | default = 5s ]
  # Retry upon receiving a 429 status code from the remote-write storage.
  # This is experimental and might change in the future.
  [ retry_on_http_429: <boolean> | default = false ]
  # If set, any sample that is older than sample_age_limit
  # will not be sent to the remote storage. The default value is 0s,
  # which means that all samples are sent.
  [ sample_age_limit: <duration> | default = 0s ]

# Configures the sending of series metadata to remote storage
# if the `prometheus.WriteRequest` message was chosen. When
# `io.prometheus.write.v2.Request` is used, metadata is always sent.
#
# Metadata configuration is subject to change at any point
# or be removed in future releases.
metadata_config:
  # Whether metric metadata is sent to remote storage or not.
  [ send: <boolean> | default = true ]
  # How frequently metric metadata is sent to remote storage.
  [ send_interval: <duration> | default = 1m ]
  # Maximum number of samples per send.
  [ max_samples_per_send: <int> | default = 500]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
# enable_http2 defaults to false for remote-write.
[ <http_config> ]
There is a list of integrations with this feature.

<remote_read>
# The URL of the endpoint to query from.
url: <string>

# Name of the remote read config, which if specified must be unique among remote read configs.
# The name will be used in metrics and logging in place of a generated value to help users distinguish between
# remote read configs.
[ name: <string> ]

# An optional list of equality matchers which have to be
# present in a selector to query the remote read endpoint.
required_matchers:
  [ <labelname>: <labelvalue> ... ]

# Timeout for requests to the remote read endpoint.
[ remote_timeout: <duration> | default = 1m ]

# Custom HTTP headers to be sent along with each remote read request.
# Be aware that headers that are set by Prometheus itself can't be overwritten.
headers:
  [ <string>: <string> ... ]

# Whether reads should be made for queries for time ranges that
# the local storage should have complete data for.
[ read_recent: <boolean> | default = false ]

# Whether to use the external labels as selectors for the remote read endpoint.
[ filter_external_labels: <boolean> | default = true ]

# HTTP client settings, including authentication methods (such as basic auth and
# authorization), proxy configurations, TLS options, custom HTTP headers, etc.
[ <http_config> ]
There is a list of integrations with this feature.

<tsdb>
tsdb lets you configure the runtime-reloadable configuration settings of the TSDB.

# Configures how old an out-of-order/out-of-bounds sample can be w.r.t. the TSDB max time.
# An out-of-order/out-of-bounds sample is ingested into the TSDB as long as the timestamp
# of the sample is >= TSDB.MaxTime-out_of_order_time_window.
#
# When out_of_order_time_window is >0, the errors out-of-order and out-of-bounds are
# combined into a single error called 'too-old'; a sample is either (a) ingestible
# into the TSDB, i.e. it is an in-order sample or an out-of-order/out-of-bounds sample
# that is within the out-of-order window, or (b) too-old, i.e. not in-order
# and before the out-of-order window.
#
# When out_of_order_time_window is greater than 0, it also affects experimental agent. It allows
# the agent's WAL to accept out-of-order samples that fall within the specified time window relative
# to the timestamp of the last appended sample for the same series.
[ out_of_order_time_window: <duration> | default = 0s ]
<exemplars>
Note that exemplar storage is still considered experimental and must be enabled via --enable-feature=exemplar-storage.

# Configures the maximum size of the circular buffer used to store exemplars for all series. Resizable during runtime.
[ max_exemplars: <int> | default = 100000 ]
<tracing_config>
tracing_config configures exporting traces from Prometheus to a tracing backend via the OTLP protocol. Tracing is currently an experimental feature and could change in the future.

# Client used to export the traces. Options are 'http' or 'grpc'.
[ client_type: <string> | default = grpc ]

# Endpoint to send the traces to. Should be provided in format <host>:<port>.
[ endpoint: <string> ]

# Sets the probability a given trace will be sampled. Must be a float from 0 through 1.
[ sampling_fraction: <float> | default = 0 ]

# If disabled, the client will use a secure connection.
[ insecure: <boolean> | default = false ]

# Key-value pairs to be used as headers associated with gRPC or HTTP requests.
headers:
  [ <string>: <string> ... ]

# Compression key for supported compression types. Supported compression: gzip.
[ compression: <string> ]

# Maximum time the exporter will wait for each batch export.
[ timeout: <duration> | default = 10s ]

# TLS configuration.
tls_config:
  [ <tls_config> ]





On this page

Configuration file
<scrape_config>
<http_config>
<tls_config>
<oauth2>
<azure_sd_config>
<consul_sd_config>
<digitalocean_sd_config>
<docker_sd_config>
<dockerswarm_sd_config>
<dns_sd_config>
<ec2_sd_config>
<openstack_sd_config>
<ovhcloud_sd_config>
<puppetdb_sd_config>
<file_sd_config>
<gce_sd_config>
<hetzner_sd_config>
<http_sd_config>
<ionos_sd_config>
<kubernetes_sd_config>
<kuma_sd_config>
<lightsail_sd_config>
<linode_sd_config>
<marathon_sd_config>
<nerve_sd_config>
<nomad_sd_config>
<serverset_sd_config>
<stackit_sd_config>
<triton_sd_config>
<eureka_sd_config>
<scaleway_sd_config>
<uyuni_sd_config>
<vultr_sd_config>
<static_config>
<relabel_config>
<metric_relabel_configs>
<alert_relabel_configs>
<alertmanager_config>
<remote_write>
<remote_read>
<tsdb>
<exemplars>
<tracing_config>
© Prometheus Authors 2014-2025 | Documentation Distributed under CC-BY-4.0

© 2025 The Linux Foundation. All rights reserved. The Linux Foundation has registered trademarks and uses trademarks. For a list of trademarks of The Linux Foundation, please see our Trademark Usage page.

Defining recording rules
Configuring rules
Prometheus supports two types of rules which may be configured and then evaluated at regular intervals: recording rules and alerting rules. To include rules in Prometheus, create a file containing the necessary rule statements and have Prometheus load the file via the rule_files field in the Prometheus configuration. Rule files use YAML.

The rule files can be reloaded at runtime by sending SIGHUP to the Prometheus process. The changes are only applied if all rule files are well-formatted.

Syntax-checking rules
To quickly check whether a rule file is syntactically correct without starting a Prometheus server, you can use Prometheus's promtool command-line utility tool:

promtool check rules /path/to/example.rules.yml
The promtool binary is part of the prometheus archive offered on the project's download page.

When the file is syntactically valid, the checker prints a textual representation of the parsed rules to standard output and then exits with a 0 return status.

If there are any syntax errors or invalid input arguments, it prints an error message to standard error and exits with a 1 return status.

Recording rules
Recording rules allow you to precompute frequently needed or computationally expensive expressions and save their result as a new set of time series. Querying the precomputed result will then often be much faster than executing the original expression every time it is needed. This is especially useful for dashboards, which need to query the same expression repeatedly every time they refresh.

Recording and alerting rules exist in a rule group. Rules within a group are run sequentially at a regular interval, with the same evaluation time. The names of recording rules must be valid metric names. The names of alerting rules must be valid label values.

The syntax of a rule file is:

groups:
  [ - <rule_group> ]
A simple example rules file would be:

groups:
  - name: example
    rules:
    - record: code:prometheus_http_requests_total:sum
      expr: sum by (code) (prometheus_http_requests_total)
<rule_group>
# The name of the group. Must be unique within a file.
name: <string>

# How often rules in the group are evaluated.
[ interval: <duration> | default = global.evaluation_interval ]

# Limit the number of alerts an alerting rule and series a recording
# rule can produce. 0 is no limit.
[ limit: <int> | default = 0 ]

# Offset the rule evaluation timestamp of this particular group by the specified duration into the past.
[ query_offset: <duration> | default = global.rule_query_offset ]

# Labels to add or overwrite before storing the result for its rules.
# Labels defined in <rule> will override the key if it has a collision.
labels:
  [ <labelname>: <labelvalue> ]

rules:
  [ - <rule> ... ]
<rule>
The syntax for recording rules is:

# The name of the time series to output to. Must be a valid metric name.
record: <string>

# The PromQL expression to evaluate. Every evaluation cycle this is
# evaluated at the current time, and the result recorded as a new set of
# time series with the metric name as given by 'record'.
expr: <string>

# Labels to add or overwrite before storing the result.
labels:
  [ <labelname>: <labelvalue> ]
The syntax for alerting rules is:

# The name of the alert. Must be a valid label value.
alert: <string>

# The PromQL expression to evaluate. Every evaluation cycle this is
# evaluated at the current time, and all resultant time series become
# pending/firing alerts.
expr: <string>

# Alerts are considered firing once they have been returned for this long.
# Alerts which have not yet fired for long enough are considered pending.
[ for: <duration> | default = 0s ]

# How long an alert will continue firing after the condition that triggered it
# has cleared.
[ keep_firing_for: <duration> | default = 0s ]

# Labels to add or overwrite for each alert.
labels:
  [ <labelname>: <tmpl_string> ]

# Annotations to add to each alert.
annotations:
  [ <labelname>: <tmpl_string> ]
See also the best practices for naming metrics created by recording rules.

Limiting alerts and series
A limit for alerts produced by alerting rules and series produced recording rules can be configured per-group. When the limit is exceeded, all series produced by the rule are discarded, and if it's an alerting rule, all alerts for the rule, active, pending, or inactive, are cleared as well. The event will be recorded as an error in the evaluation, and as such no stale markers are written.

Rule query offset
This is useful to ensure the underlying metrics have been received and stored in Prometheus. Metric availability delays are more likely to occur when Prometheus is running as a remote write target due to the nature of distributed systems, but can also occur when there's anomalies with scraping and/or short evaluation intervals.

Failed rule evaluations due to slow evaluation
If a rule group hasn't finished evaluating before its next evaluation is supposed to start (as defined by the evaluation_interval), the next evaluation will be skipped. Subsequent evaluations of the rule group will continue to be skipped until the initial evaluation either completes or times out. When this happens, there will be a gap in the metric produced by the recording rule. The rule_group_iterations_missed_total metric will be incremented for each missed iteration of the rule group.

