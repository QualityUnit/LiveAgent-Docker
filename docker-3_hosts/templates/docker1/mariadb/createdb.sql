use mysql;
create user 'LAuser'@'%' identified by 'DATABASE_PASSWORD';
create database liveagent;
GRANT ALL PRIVILEGES ON liveagent.* TO 'LAuser'@'%' WITH GRANT OPTION;
