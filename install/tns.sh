#!/bin/bash

set -e

export ho=`hostname -I|awk '{print $1}'`
export ORACLE_HOME=/u01/app/oracle/product/18.0.0/dbhome_1

echo "ORCL18=(DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = "$ho")(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = ORCL18)))" > $ORACLE_HOME/network/admin/tnsnames.ora
echo "PDB18C=(DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = "$ho")(PORT = 1521))) (CONNECT_DATA = (SERVICE_NAME = PDB18C)))" >> $ORACLE_HOME/network/admin/tnsnames.ora
