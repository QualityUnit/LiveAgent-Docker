#!/bin/bash
#
# This script checks if a mysql server is healthy running on localhost. It will
# return:
#
# "HTTP/1.x 200 OK" (if mysql is running smoothly)
#
# - OR -
#
# "HTTP/1.x 500 Internal Server Error" (else)
#
# The purpose of this script is to make haproxy capable of monitoring mysql properly
#
#set -x
#set -e

MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USERNAME="mysqlchkusr"
MYSQL_PASSWORD="MYSQLCHK_PASS"

TMP_FILE="/tmp/mysqlchk.$$.out"
ERR_FILE="/tmp/mysqlchk.$$.err"

#
# We perform a simple query that should return a few results
#
docker exec -i mysql mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD -e"select 1;" > $TMP_FILE 2> $ERR_FILE

#
# Check the output. If it is not empty then everything is fine and we return
# something. Else, we just do not return anything.
#
if [ "$(/bin/cat $TMP_FILE)" != "" ]
then
    # mysql is fine, return http 200
    echo -en "HTTP/1.1 200 OK\r\n"
    echo -en "Content-Type: text/plain\r\n"
    echo -en "Connection: close\r\n"
    echo -en "Content-Length: 40\r\n"
    echo -en "\r\n"
    echo -en "Mysql is running.\r\n"
    sleep 0.1
    rm $TMP_FILE
    rm $ERR_FILE
    exit 0
else
    # mysql is not fine, return http 503
    echo -en "HTTP/1.1 503 Service Unavailable\r\n"
    echo -en "Content-Type: text/plain\r\n"
    echo -en "Connection: close\r\n"
    echo -en "Content-Length: 44\r\n"
    echo -en "\r\n"
    echo -en "Mysql is not running\r\n"
    cat $ERR_FILE
    echo -en "\r\n"
    sleep 0.1
    rm $TMP_FILE
    rm $ERR_FILE
    exit 1
fi
