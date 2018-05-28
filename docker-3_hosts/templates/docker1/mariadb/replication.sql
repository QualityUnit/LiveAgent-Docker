use mysql;
stop slave;
CHANGE MASTER TO MASTER_HOST = 'PRIVATE_IP_2', MASTER_USER = 'replicator', MASTER_PASSWORD = 'MYSQL_REPLICATOR_PASS', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 1366;
start slave;
show slave status\G
