docker compose up -d

# Écrire sur le primaire
docker exec pg-primary psql -U app -d appdb -c "CREATE TABLE t(id int); INSERT INTO t VALUES (1);"

# Lire sur le replica
docker exec pg-replica psql -U app -d appdb -c "SELECT * FROM t;"

# -- Entree dans le primaire
docker exec -it pg-primary psql -U app -d appdb

# Écrire sur le replica : doit échouer
docker exec pg-replica psql -U app -d appdb -c "INSER T INTO t VALUES (2);"

# État de la réplication
docker exec pg-primary psql -U app -d appdb -c "SELECT client_addr, state FROM pg_stat_replication;"

# -- Entree dans le replica
docker exec -it pg-replica psql -U app -d appdb