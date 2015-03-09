#!/bin/sh
# this script is run as the entry point for the cotainer
# logic as follows
# Check to see if the mysql data volume has been initialized.
#   if initialized, start up supervisord, which will start mysql
#   if not initialized, then initialized mysql

StartMySQL ()
{
    /usr/bin/mysqld_safe > /dev/null 2>&1 &

    # Time out in 1 minute
    LOOP_LIMIT=13
    for (( i=0 ; ; i++ )); do
        if [ ${i} -eq ${LOOP_LIMIT} ]; then
            echo "Time out. Error log is shown as below:"
            tail -n 100 ${LOG}
            exit 1
        fi
        echo "=> Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..."
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1 && break
    done
}

#main
# DATADIR = /var/lib/mysql
DATADIR='/var/lib/mysql'
LOG="/var/log/mysql/error.log"


# check to see if database has been initialized
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    # exit if the root password was expected by not proived
    if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" ]; then
        echo >&2 'error: database is uninitialized and MYSQL_ROOT_PASSWORD not set'
        echo >&2 '  Did you forget to add -e MYSQL_ROOT_PASSWORD=... ?'
        exit 1
    fi

    echo 'Running mysql_install_db ...'
    mysql_install_db --datadir="$DATADIR"
    echo 'Finished mysql_install_db'
    # set owner of datadirectory to mysql, This means that supervisord must start mysqld as user mysql
    chown -R mysql:mysql "$DATADIR"

    # These statements _must_ be on individual lines, and _must_ end with
    # semicolons (no line breaks or comments are permitted).
    # TODO proper SQL escaping on ALL the things D:

    tempSqlFile='/tmp/mysql-first-time.sql'
    cat > "$tempSqlFile" <<-EOSQL
        DELETE FROM mysql.user ;
        CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
        GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
        DROP DATABASE IF EXISTS test ;
EOSQL

    if [ "$MYSQL_DATABASE" ]; then
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" >> "$tempSqlFile"
    fi

    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
        echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> "$tempSqlFile"

        if [ "$MYSQL_DATABASE" ]; then
            echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" >> "$tempSqlFile"
        fi
    fi

    echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"

    # now start mysqld
    StartMySQL
    # run the initial sql
    mysql -uroot < "$tempSqlFile"

    # shutdown mysql
    mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown
fi
# start supervisord
echo "Starting supervisord"
/usr/bin/supervisord -c /etc/supervisord.conf
echo "Done run.sh"
