# Guia de Monitoramento de Aplicações com Prometheus e Grafana

Este guia prático irá te ajudar a entender como o Prometheus coleta métricas e como o Grafana as visualiza, usando o Traefik como nosso exemplo de aplicação a ser monitorada.

## 🚀 Introdução ao Monitoramento

No mundo da engenharia de software, saber o que está acontecendo com suas aplicações é crucial. É aqui que entram o **Prometheus** e o **Grafana**:

*   **Prometheus:** É um sistema de monitoramento e alerta de código aberto. Ele coleta e armazena métricas de diversas fontes (suas aplicações, servidores, bancos de dados, etc.). Pense nele como o "coletor de dados" do seu ambiente.
*   **Grafana:** É uma plataforma de código aberto para análise e visualização de dados. Ele se conecta a diversas fontes de dados (como o Prometheus) e permite que você crie dashboards interativos e bonitos para entender o comportamento das suas aplicações. Pense nele como o "painel de controle" do seu ambiente.

## 1. Prometheus: Coletando as Métricas do Traefik

Para que o Grafana possa exibir dados, o Prometheus precisa primeiro coletá-los. No nosso setup, já configuramos o Prometheus para coletar métricas do Traefik.

### 1.1. Como o Prometheus Coleta Métricas?

O Prometheus funciona puxando (pulling) métricas de "endpoints" HTTP expostos pelas aplicações. No caso do Traefik, ele já expõe suas métricas em uma porta específica (`9100` por padrão no Helm chart).

No arquivo `monitoring/prometheus-values.yaml`, a seção `extraScrapeConfigs` (ou `serviceMonitor` se você refatorou) instrui o Prometheus a procurar por pods do Traefik e coletar métricas da porta `9100`.

### 1.2. Verificando se o Prometheus está Coletando Dados

Você pode verificar diretamente no dashboard do Prometheus se ele está coletando as métricas do Traefik.

1.  Acesse o dashboard do Prometheus no seu navegador: `https://prometheus.local.dev`
2.  Faça login com as credenciais que você configurou (admin/admin).
3.  No menu superior, vá em **Status** -> **Targets**.
4.  Procure por um target com o `job` `traefik`. Ele deve estar no estado `UP` (verde), indicando que o Prometheus está coletando métricas com sucesso.

Você também pode ir em **Graph** e digitar `traefik_` na barra de expressão. Você verá várias métricas do Traefik aparecerem no autocompletar. Selecione uma (ex: `traefik_entrypoint_requests_total`) e clique em "Execute" para ver os dados.

## 2. Grafana: Visualizando as Métricas do Traefik

Agora que o Prometheus está coletando os dados, o Grafana pode acessá-los e transformá-los em dashboards úteis.

### 2.1. Acessando o Grafana

1.  Abra seu navegador e acesse: `https://grafana.local.dev`
2.  Faça login com o usuário `admin` e a senha que você definiu no Secret (`admin` por padrão).

### 2.2. Verificando a Fonte de Dados do Prometheus

O Grafana precisa saber onde encontrar o Prometheus. No nosso `monitoring/grafana-values.yaml`, já configuramos isso.

1.  No Grafana, clique no ícone de engrenagem (Configuration) no menu lateral esquerdo.
2.  Selecione **Data sources**.
3.  Você deve ver uma fonte de dados chamada `Prometheus` com o tipo `Prometheus`. Clique nela para verificar os detalhes. A URL deve ser `http://prometheus-server.monitoring-prometheus.svc.cluster.local`.

### 2.3. Explorando Métricas no Grafana

Antes de criar um dashboard, é útil explorar as métricas para entender o que está disponível.

1.  No Grafana, clique no ícone de bússola (Explore) no menu lateral esquerdo.
2.  No seletor de fonte de dados, escolha `Prometheus`.
3.  Na barra de expressão (onde diz "Metric browser"), comece a digitar `traefik_`. Você verá uma lista de métricas relacionadas ao Traefik. Selecione uma e clique em "Run query" para ver os dados.

### 2.4. Criando um Dashboard para o Traefik (Importando)

A forma mais rápida e eficiente de ter um dashboard completo é importar um já existente da comunidade Grafana Labs. Existem muitos dashboards de alta qualidade disponíveis.

Vamos importar um dashboard oficial do Traefik.

1.  No Grafana, clique no ícone de Dashboards (quatro quadrados) no menu lateral esquerdo.
2.  Selecione **Import**.
3.  No campo "Import via grafana.com", insira o ID do dashboard. Um bom dashboard para o Traefik 2.x é o **ID: `17346`** (Traefik Official Standalone Dashboard).
4.  Clique em **Load**.
5.  Na próxima tela, você pode renomear o dashboard se quiser. Em "Prometheus", selecione a fonte de dados `Prometheus` que configuramos.
6.  Clique em **Import**.

Pronto! Você terá um dashboard completo exibindo diversas métricas do seu Traefik, como requisições por segundo, erros, latência, uso de CPU/memória, etc.

### 2.5. Métricas Chave do Traefik para Observar

Ao explorar ou visualizar o dashboard, preste atenção a métricas como:

*   `traefik_entrypoint_requests_total`: Número total de requisições recebidas por um entrypoint.
*   `traefik_entrypoint_requests_bytes_total`: Volume de dados de requisições.
*   `traefik_entrypoint_responses_total`: Número total de respostas por código de status (2xx, 3xx, 4xx, 5xx).
*   `traefik_entrypoint_request_duration_seconds_bucket`: Métricas de latência das requisições (útil para SLOs).
*   `traefik_router_requests_total`: Requisições por roteador.
*   `traefik_service_requests_total`: Requisições por serviço (sua aplicação).

## 3. Próximos Passos

Agora que você tem um dashboard funcional para o Traefik, você pode:

*   **Explorar outras métricas:** Use a função "Explore" no Grafana para entender mais sobre os dados que o Prometheus coleta.
*   **Criar seus próprios painéis:** Comece a construir painéis personalizados para suas próprias aplicações, usando as métricas que elas expõem.
*   **Configurar alertas:** No Grafana, você pode configurar alertas para ser notificado quando certas métricas atingirem limites críticos (ex: muitos erros 5xx).

Monitoramento é uma jornada contínua. Quanto mais você explora e entende seus dados, melhor você pode otimizar e garantir a saúde das suas aplicações!

---

**Nota sobre o Monitoramento de Host (Node Exporter):**

Durante o desenvolvimento deste guia, encontramos desafios significativos ao tentar implantar o Node Exporter (ferramenta para coletar métricas de CPU, memória, disco, etc. do host) como um contêiner no Kubernetes do Docker Desktop. Isso se deve a complexidades e limitações na forma como o Docker Desktop lida com montagens de sistema de arquivos do host (`HostPath`) e namespaces de rede/PID para contêineres que precisam acessar o sistema operacional subjacente.

Embora o Node Exporter seja uma ferramenta essencial para monitoramento de infraestrutura em ambientes de produção (como em uma VPS ou cluster de nuvem), sua configuração robusta em um ambiente local como o Docker Desktop pode exigir soluções mais avançadas ou específicas que fogem do escopo introdutório deste tutorial.

Para manter o foco nos conceitos de monitoramento de aplicações e evitar complexidades desnecessárias neste estágio, decidimos concentrar este guia no monitoramento do Traefik. Em um ambiente de produção real, a implantação do Node Exporter seria mais direta e recomendada.
