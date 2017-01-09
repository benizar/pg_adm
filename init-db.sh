#!/bin/bash -e

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"


echo "Load extensions into $POSTGRES_DB"
for DB in "$POSTGRES_DB"; do

	"${psql[@]}" --dbname="$DB" <<-'EOSQL'

		CREATE EXTENSION IF NOT EXISTS pg_sakila_db;
		CREATE EXTENSION IF NOT EXISTS pg_buffercache;
		CREATE EXTENSION IF NOT EXISTS pg_adm;
EOSQL
done
