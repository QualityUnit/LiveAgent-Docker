use mysql;
create user 'LAuser'@'%' identified by 'DATABASE_PASSWORD';
create database liveagent;
GRANT ALL PRIVILEGES ON liveagent.* TO 'LAuser'@'%' WITH GRANT OPTION;
grant select on mysql.* to 'mysqlchkusr'@'localhost' identified by 'MYSQLCHK_PASS' with grant option;
