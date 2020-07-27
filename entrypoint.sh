#!/bin/bash
set -e

# Start MongoDB
mongod &

# Check Leanote state
echo Checking Leanote status...
if [ ! -d "/data/leanote" ]; then
        echo Leanote is not installed
        echo Installing Leanote...
        tar zxf /data_tmp/leanote-linux-amd64-v2.6.1.bin.tar.gz -C /data/
        chmod a+x /data/leanote/bin/run.sh
        SECRET="`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c64 | sed 's/[ \r\b]/a/g'`"
        sed -i "s/V85ZzBeTnzpsHyjQX4zukbQ8qqtju9y2aDM55VWxAH9Qop19poekx3xkcDVvrD0y/$SECRET/g" /data/leanote/conf/app.conf
        mkdir /data/backup >/dev/null 2>&1
        mkdir /data/restore >/dev/null 2>&1
fi
echo -e "\033[32mLeanote is installed \033[0m"

# Check wkhtmltox state
echo Checking wkhtmltox status...
if [ ! -d "/wkhtmltox" ]; then
        echo wkhtmltox is not installed
        echo wkhtmltox Leanote...
        tar zxf /data_tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.gz -C /
        cp /wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
        chmod +x /usr/bin/wkhtmltopdf
fi
echo -e "\033[32mLeanote is installed \033[0m"

# Check mongodb data
echo Checking MongoDB status...
if [ ! -f "/data/db/.do_not_delete" ]; then
        echo No database
        echo Initializing MongoDB...
        mongorestore -h localhost -d leanote --dir /data/leanote/mongodb_backup/leanote_install_data/
        echo "do not delete this file" >> /data/db/.do_not_delete
        chmod 400 /data/db/.do_not_delete
        echo Done
fi
echo -e "\033[32mMongoDB is initialized \033[0m"

# Restore Leanote
RESTORE_DIR=/data/restore
if [ -f $RESTORE_DIR/leanote*.tar.gz ]; then
        echo Restoring Leanote...
        cp /data/leanote/bin/leanote* $RESTORE_DIR
        cp /data/leanote/bin/run* $RESTORE_DIR
        rm -rf /data/leanote
        tar zxf $RESTORE_DIR/leanote*.tar.gz -C /data/
        rm -f $RESTORE_DIR/leanote*.tar.gz
        rm -f /data/leanote/bin/leanote*
        rm -f /data/leanote/bin/run*
        mv $RESTORE_DIR/leanote* /data/leanote/bin
        mv $RESTORE_DIR/run* /data/leanote/bin
        echo Done
fi

# Restore MongoDB
if [ -f $RESTORE_DIR/mongodb*.tar.gz ]; then
        echo Restoring MongoDB...
        mongo leanote --eval "db.dropDatabase()" 
        tar zxf $RESTORE_DIR/mongodb*.tar.gz -C $RESTORE_DIR/
        mongorestore -h localhost -d leanote --dir $RESTORE_DIR/leanote/
        rm -rf $RESTORE_DIR/leanote
        rm -f $RESTORE_DIR/mongodb*.tar.gz
        echo Done
fi

# Setting Leanote
sed -i "48ci18n.default_language=$LANG" /data/leanote/conf/app.conf
sed -i "11cadminUsername=$ADMINUSER" /data/leanote/conf/app.conf
sed -i "8csite.url=$SITEURL" /data/leanote/conf/app.conf

# Start Leanote
echo `date "+%Y-%m-%d %H:%M:%S"`' >>>>>> start leanote service'
/data/leanote/bin/run.sh &

# Auto Backup
if [ $DAYS -gt 0 ]; then
        BACKUP_DIR=/data/backup
        HOUR=`date "+%-H"`
        MIN=`date "+%-M"`
        SEC=`date "+%-S"`
        seconds=$((10#86400-${HOUR}*3600-${MIN}*60-${SEC}))
        echo ++++++++Start Counting $seconds s++++++++
        sleep $seconds
fi
while [ $DAYS -gt 0 ]; do
        TIME=`date "+%Y%m%d_%H%M"`
        mongodump -h 127.0.0.1:27017 -d leanote -o $BACKUP_DIR/
        tar -zcvf $BACKUP_DIR/mongodb_bak_$TIME.tar.gz -C $BACKUP_DIR leanote
        tar -zcvf $BACKUP_DIR/leanote_bak_$TIME.tar.gz -C /data leanote
        rm -rf $BACKUP_DIR/leanote
        find $BACKUP_DIR/ -mtime +$DAYS -delete
        HOUR=`date "+%H"`
        MIN=`date "+%M"`
        SEC=`date "+%S"`
        seconds=$((10#86400-${HOUR}*3600-${MIN}*60-${SEC}))
        sleep $seconds
done

exec "$@"
