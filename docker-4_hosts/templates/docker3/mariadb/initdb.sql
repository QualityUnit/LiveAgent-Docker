grant select on mysql.* to 'mysqlchkusr'@'localhost' identified by 'MYSQLCHK_PASS' with grant option;
create user 'replicator'@'%' identified by 'MYSQL_REPLICATOR_PASS';
grant replication slave on *.* to 'replicator'@'%';
CREATE USER 'backup'@'localhost' IDENTIFIED BY 'MYSQL_BACKUP_PASS';
GRANT SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'backup'@'localhost';
FLUSH PRIVILEGES;
CHANGE MASTER TO MASTER_HOST = 'PRIVATE_IP_4', MASTER_USER = 'replicator', MASTER_PASSWORD = 'MYSQL_REPLICATOR_PASS';
start slave;
show slave status\G
