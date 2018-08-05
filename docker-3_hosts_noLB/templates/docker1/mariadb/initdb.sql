grant select on mysql.* to 'mysqlchkusr'@'localhost' identified by 'MYSQLCHK_PASS' with grant option;
create user 'replicator'@'%' identified by 'MYSQL_REPLICATOR_PASS';
grant replication slave on *.* to 'replicator'@'%';
FLUSH PRIVILEGES;
CHANGE MASTER TO MASTER_HOST = 'PRIVATE_IP_2', MASTER_USER = 'replicator', MASTER_PASSWORD = 'MYSQL_REPLICATOR_PASS';
start slave;
create user 'LAuser'@'%' identified by 'DATABASE_PASSWORD';
create database liveagent;
GRANT ALL PRIVILEGES ON liveagent.* TO 'LAuser'@'%' WITH GRANT OPTION;
