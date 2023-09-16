docker exec master sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'create table if not exists users(id int, email varchar(256), name varchar(256), phone varchar(15), gender boolean);'"

docker exec master sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'insert into users values (\"$1\", \"$2\", \"$3\", \"$4\", \"$5\")'"
