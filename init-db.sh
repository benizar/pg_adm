#!/bin/bash -e

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"


echo "Creating testdb"
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE testdb;
EOSQL



echo "Load pg_adm in testdb and $POSTGRES_DB"
for DB in testdb "$POSTGRES_DB"; do
	echo "Loading pg_adm extension into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'

		CREATE EXTENSION IF NOT EXISTS pg_buffercache;
		CREATE EXTENSION IF NOT EXISTS pg_adm;

EOSQL
done



