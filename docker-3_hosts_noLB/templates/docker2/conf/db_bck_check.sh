#/bin/bash
#
#Script to check if backup of slave is possible.
#

docker exec -i mysql mysql --host=localhost --port=3306 --user=backup --password=MYSQL_BACKUP_PASS -e"show slave status\G" | grep "Seconds_Behind_Master: 0"

if [ $? -eq 0 ]; then
    docker exec mysql /usr/bin/mysqldump --single-transaction -u backup --password=MYSQL_BACKUP_PASS liveagent > BACKUP_PATH/backup.sql && gzip -9c BACKUP_PATH/backup.sql > BACKUP_PATH/backup.sql."$(date +%Y%m%d)".gz && rm -f BACKUP_PATH/backup.sql
else
    logger -t Backup-Cron - Backup failed. Master is not online or slave is not fully replicated.
fi
