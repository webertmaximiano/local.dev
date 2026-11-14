# PostgreSQL compartilhado local

Esta stack fornece uma única instância `postgis/postgis:18-3.6-alpine` para aplicações locais, isolada da rede de entrada do Traefik. A imagem corresponde à usada no serviço PostgreSQL de produção do EstouOn Food.

## Operação

Na raiz de `www/local.dev`:

```bash
make postgres-up
make status
make logs-postgres
```

O serviço não publica a porta `5432` no host. Aplicações Swarm autorizadas devem se conectar pela rede overlay externa `db-local`, usando o alias `local-postgres:5432`. Não conecte o PDV à rede interna geral do EstouOn.

`make postgres-down` remove apenas os serviços da stack. O volume externo `local_postgres_data` e o Docker Secret `local_postgres_admin_password` permanecem intactos. Não remova o volume para resolver problemas de inicialização.

## Isolamento das aplicações

Cada projeto deve receber seu próprio database e role PostgreSQL. Nunca reutilize o database ou role do EstouOn, não exponha o usuário administrativo a aplicações e não publique a porta no host. O provisionamento do database/role do PDV será documentado com a stack local do PDV e usará um segredo próprio.

O limite de 1,5 GiB e `shared_buffers=256MB` são valores iniciais para o laboratório local; devem ser medidos antes de qualquer decisão de capacidade em produção.

## Testes em paralelo (`php artisan test --parallel`)

Cada processo do ParaTest usa um banco próprio (`<banco>_test_1`, `_test_2`, ...). A role da aplicação não pode criar bancos nem extensões como PostGIS, então o administrador cria esses bancos uma vez:

```bash
make postgres-test-databases DB=estouon_food_testing ROLE=estouon COUNT=4 EXTENSIONS="postgis pg_trgm unaccent uuid-ossp"
```

O comando é seguro para repetir: só cria o que falta, nunca apaga, só aceita bancos-base terminados em `_testing` e extensões de uma lista fixa. A role não ganha `CREATEDB` nem acesso aos bancos de desenvolvimento. O número de processos dos testes não deve passar de `COUNT`.
