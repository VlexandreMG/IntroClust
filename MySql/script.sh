docker compose up -d
# Entree primary 
docker exec -it mysql-primary mysql -uroot -pchange_me

# Entree replica
docker exec -it mysql-replica mysql -uroot -pchange_me

# Creer un utilisateur avec les droits de réplication sur le primaire
docker exec -it mysql-primary mysql -uroot -pchange_me -e "CREATE USER 'replicator'@'%' IDENTIFIED BY 'change_me_too'; GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%'; FLUSH PRIVILEGES;"
# Relancer la replication 
docker exec -it mysql-replica mysql -uroot -pchange_me -e "STOP REPLICA; START REPLICA;"

# Vérifier la réplication (IO et SQL doivent être "Yes")
docker exec mysql-replica mysql -uroot -pchange_me -e "SHOW REPLICA STATUS\G" | grep -E "Running|Error"

# Écrire sur le primaire
docker exec mysql-primary mysql -uroot -pchange_me -e "CREATE DATABASE IF NOT EXISTS test; CREATE TABLE test.t(id INT); INSERT INTO test.t VALUES (1);"

# Lire sur le replica
docker exec mysql-replica mysql -uroot -pchange_me -e "SELECT * FROM test.t;"

# Écrire sur le replica : doit échouer
docker exec mysql-replica mysql -uroot -pchange_me -e "INSERT INTO test.t VALUES (2);"

# Entree primary 
docker exec -it mysql-primary mysql -uroot -pchange_me

# Entree replica
docker exec -it mysql-replica mysql -uroot -pchange_me