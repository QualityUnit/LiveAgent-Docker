use mysql;
grant select on mysql.* to 'mysqlchkusr'@'localhost' identified by 'MYSQLCHK_PASS' with grant option;
create user 'replicator'@'%' identified by 'MYSQL_REPLICATOR_PASS';
grant replication slave on *.* to 'replicator'@'%';
# replicator permission cannot be granted on single database.
FLUSH PRIVILEGES;
SHOW MASTER STATUS;
SHOW VARIABLES LIKE 'server_id';
