#!/bin/bash
set -e
PGDATA=/var/lib/postgresql/data

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "Copie initiale depuis le primaire..."
  mkdir -p "$PGDATA"
  chown postgres:postgres "$PGDATA"
  chmod 700 "$PGDATA"
  gosu postgres env PGPASSWORD="$REPLICATION_PASSWORD" \
    pg_basebackup -h primary -U replicator -D "$PGDATA" -R -X stream -P
fi

exec gosu postgres postgres -c hot_standby=on