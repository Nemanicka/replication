#!/bin/bash

docker compose down -v
docker rm $(docker ps -aq)
rm -rf ./master/data/*
rm -rf ./slave/data1/*
rm -rf ./slave/data2/*
rm -rf ./slave/data3/*
docker compose build
docker compose up &

until docker exec master sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for master database connection..."
    sleep 4
done

priv_stmt='CREATE USER "mydb_slave_user"@"%" IDENTIFIED BY "mydb_slave_pwd"; GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user"@"%"; FLUSH PRIVILEGES;'
docker exec master sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt'"

until docker exec slave1 sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for slave1 database connection..."
    sleep 4
done
until docker exec slave2 sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for slave2 database connection..."
    sleep 4
done
until docker exec slave3 sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for slave3 database connection..."
    sleep 4
done

MS_STATUS=`docker exec master sh -c 'export MYSQL_PWD=111; mysql -u root -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='master',MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'

docker exec slave1 sh -c "$start_slave_cmd"
docker exec slave1 sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
docker exec slave2 sh -c "$start_slave_cmd"
docker exec slave2 sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
docker exec slave3 sh -c "$start_slave_cmd"
docker exec slave3 sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
