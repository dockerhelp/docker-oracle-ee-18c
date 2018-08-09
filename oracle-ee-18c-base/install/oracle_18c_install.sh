#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "No rsp file specified"
    exit 1
elif [ ! -f $1 ]; then
	echo "Can't find RSP file $1"
	exit 1
fi

#sysctl workaround
echo 'exit 0' > /usr/sbin/sysctl

groupadd dba && useradd -m -G dba oracle
mkdir /u01 && chown oracle:dba /u01 && chmod 775 /u01

#Download oracle database zip
echo "Downloading oracle database zip"
wget -q --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=15CLHkPZzwih26oINeXvIB79Jny8zgqWh' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=15CLHkPZzwih26oINeXvIB79Jny8zgqWh" -O oracle_database.zip && rm -rf /tmp/cookies.txt

#echo "Extracting oracle database zip"
#su oracle -c 'unzip -q /oracle_database.zip -d /home/oracle/'
#rm -f /oracle_database.zip

#Run installer
#su oracle -c "cd /home/oracle/database && ./runInstaller -skipPrereqs -silent -responseFile $1 -waitForCompletion"
#Cleanup
#echo "Cleaning up"
#rm -rf /home/oracle/database /tmp/*

#Move product to custom location
#mv /u01/app/oracle/product /u01/app/oracle-product
