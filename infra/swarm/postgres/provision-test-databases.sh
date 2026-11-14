#!/usr/bin/env bash
# Cria os bancos de teste do modo paralelo do Laravel/Pest (ParaTest) no PostgreSQL
# compartilhado do Swarm local.
#
# Por que existe: `php artisan test --parallel` usa um banco por processo
# (`<banco>_test_1`, `<banco>_test_2`, ...). A role da aplicação não é superusuária e
# não pode criar bancos nem extensões como PostGIS. Este script, rodado pelo
# administrador (via `make postgres-test-databases`), cria os bancos uma vez.
#
# Segurança:
# - só aceita bancos-base que terminam em `_testing` (nunca toca banco de desenvolvimento);
# - só cria, nunca apaga (`DROP`) nem altera dados; repetir o comando não muda nada;
# - a role dona deve existir e vira dona apenas dos bancos `_test_N`;
# - extensões só de uma lista fixa;
# - não lê nem imprime segredos: o acesso administrativo é o `psql` local do próprio
#   contêiner do PostgreSQL (a senha do admin nunca passa por aqui).
#
# Uso: provision-test-databases.sh <banco_base_testing> <role_dona> [quantidade=4] ["ext1 ext2 ..."]
# Ex.: provision-test-databases.sh estouon_food_testing estouon 4 "postgis pg_trgm unaccent uuid-ossp"
set -euo pipefail

base="${1:-}"
owner="${2:-}"
count="${3:-4}"
extensions="${4:-}"

die() { echo "❌ $*" >&2; exit 1; }

[[ "$base" =~ ^[a-z][a-z0-9_]{0,40}_testing$ ]] || die "Banco-base inválido: use letras minúsculas, números e '_', terminando em _testing."
[[ "$owner" =~ ^[a-z][a-z0-9_]{0,40}$ ]] || die "Role inválida."
[[ "$count" =~ ^[0-9]+$ ]] && (( count >= 1 && count <= 16 )) || die "Quantidade deve ser de 1 a 16."

allowed_extensions=" postgis pg_trgm unaccent uuid-ossp "
for extension in $extensions; do
    [[ "$allowed_extensions" == *" $extension "* ]] || die "Extensão não permitida: $extension (permitidas:${allowed_extensions})."
done

container="$(docker ps -q -f label=com.docker.swarm.service.name=postgres_postgres | head -n1)"
[[ -n "$container" ]] || die "Serviço postgres_postgres fora do ar. Rode: make postgres-up"

psql_admin() { docker exec -i "$container" psql -U postgres -v ON_ERROR_STOP=1 -tA "$@"; }

[[ "$(psql_admin -d postgres -c "select 1 from pg_roles where rolname = '$owner'")" == "1" ]] \
    || die "A role '$owner' não existe no PostgreSQL compartilhado."

for i in $(seq 1 "$count"); do
    name="${base}_test_${i}"

    if [[ "$(psql_admin -d postgres -c "select 1 from pg_database where datname = '$name'")" == "1" ]]; then
        echo "= $name já existe"
    else
        psql_admin -d postgres -c "create database \"$name\" owner \"$owner\"" >/dev/null
        echo "+ $name criado (dono: $owner)"
    fi

    for extension in $extensions; do
        psql_admin -d "$name" -c "create extension if not exists \"$extension\"" >/dev/null
    done
done

echo "✅ ${count} banco(s) de teste prontos para '$base'. Rode os testes com --parallel --processes=${count} (ou menos)."
