use mysql;
grant select on mysql.* to 'mysqlchkusr'@'localhost' identified by 'MYSQLCHK_PASS' with grant option;
create user 'replicator'@'%' identified by 'MYSQL_REPLICATOR_PASS';
grant replication slave on *.* to 'replicator'@'%';
CREATE USER 'backup'@'localhost' IDENTIFIED BY 'MYSQL_BACKUP_PASS';
GRANT SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'backup'@'localhost';
# replicator permission cannot be granted on single database.
FLUSH PRIVILEGES;
SHOW MASTER STATUS;
SHOW VARIABLES LIKE 'server_id';
