#!/bin/bash
set -euo pipefail

PRIMARY_HOST="mysql-primary"
REPLICA_HOST="mysql-replica"

replica_sql() { MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -h "$REPLICA_HOST" -uroot "$@"; }

echo "Attente du replica..."
until replica_sql -e "SELECT 1" >/dev/null 2>&1; do sleep 2; done

echo "Attente du primaire (compte replicator)..."
until MYSQL_PWD="$REPLICATION_PASSWORD" mysql -h "$PRIMARY_HOST" -ureplicator -e "SELECT 1" >/dev/null 2>&1; do
  sleep 2
done

echo "Activation de la lecture seule..."
replica_sql -e "SET PERSIST super_read_only=ON; SET PERSIST read_only=ON;"

if [ -z "$(replica_sql -N -e 'SHOW REPLICA STATUS')" ]; then
  echo "Configuration de la réplication..."
  replica_sql <<SQL
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='${PRIMARY_HOST}',
  SOURCE_USER='replicator',
  SOURCE_PASSWORD='${REPLICATION_PASSWORD}',
  SOURCE_AUTO_POSITION=1,
  GET_SOURCE_PUBLIC_KEY=1;
SQL
else
  echo "Réplication déjà configurée."
fi

replica_sql -e "START REPLICA;"

echo "--- Statut ---"
replica_sql -e "SHOW REPLICA STATUS\G" | grep -E "Source_Host|Replica_IO_Running:|Replica_SQL_Running:|Last_.*Error:"
replica_sql -e "SHOW VARIABLES LIKE '%read_only%';"