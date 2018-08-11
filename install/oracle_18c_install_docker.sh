#!/bin/bash

set -e
export INSTALL=/
echo `hostname -I|awk '{print $1}'` `hostname -s` `hostname` >> /etc/hosts
cp /gosu /usr/local/bin/gosu  && chmod +x /usr/local/bin/gosu

rm -rf /var/cache/yum

echo "Creating Directory"
#groupadd dba && useradd -m -G dba oracle
rm -rf /u01
mkdir /u01 && mkdir -p /u01/app/oracle/product/18.0.0/dbhome_1 && chown -R oracle:oinstall /u01 && chmod -R 775 /u01
touch /etc/oratab
chmod 777 /etc/oratab

echo "Setting ENV"
echo oracle:oracle | chpasswd
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/18.0.0/dbhome_1


#Download oracle database zip
echo "Downloading oracle database zip"
wget  --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=15CLHkPZzwih26oINeXvIB79Jny8zgqWh' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=15CLHkPZzwih26oINeXvIB79Jny8zgqWh" -O oracle_database.zip && rm -rf /tmp/cookies.txt

echo "Extracting oracle database zip"
gosu oracle bash -c 'unzip -q oracle_database.zip -d /u01/app/oracle/product/18.0.0/dbhome_1/'
rm -f oracle_database.zip

echo "setting up Response files"
cp $INSTALL/oracle-18c-ee.rsp $ORACLE_HOME/oracle-18c-ee.rsp
cp $INSTALL/dbca_18c.rsp $ORACLE_HOME/dbca_18c.rsp
cp $INSTALL/netca.rsp $ORACLE_HOME/netca.rsp
chmod 777 $ORACLE_HOME/oracle-18c-ee.rsp
chmod 777 $ORACLE_HOME/dbca_18c.rsp
chmod 777 $ORACLE_HOME/netca.rsp

echo "Installing Oracle Binaries"

gosu oracle bash -c "$ORACLE_HOME/runInstaller -force -skipPrereqs -silent -responseFile $ORACLE_HOME/oracle-18c-ee.rsp -waitForCompletion"
sh $ORACLE_HOME/root.sh
echo "Done"

#Connect to Oracle
gosu oracle bash <<EOF
id
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/18.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
sqlplus -v
EOF

echo "Default 18c database install with PDB"

gosu oracle bash -c "/u01/app/oracle/product/18.0.0/dbhome_1/bin/dbca -silent -createDatabase -responseFile $ORACLE_HOME/dbca_18c.rsp"

echo "Starting default listener"
gosu oracle  bash -c "$ORACLE_HOME/bin/netca -silent -responseFile $ORACLE_HOME/netca.rsp"


echo "Configuring the TNS"
sh $INSTALL/tns.sh
chown oracle:oinstall $ORACLE_HOME/network/admin/tnsnames.ora

echo "Testing Database"
gosu oracle bash<<EOF
export ORACLE_SID=ORCL18
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/18.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
sqlplus / as sysdba
alter system register;
select name,open_mode from v\$database;
show pdbs;
EOF

echo "Cleaning up"
rm -rf /tmp/*
echo "DataBase Installed!!!"
