FROM oraclelinux

RUN yum install -y wget unzip oracle-database-preinstall-18c && yum clean all

ADD install/oracle_18c_install_docker.sh oracle_18c_install_docker.sh
ADD install/tns.sh tns.sh
ADD install/oracle-18c-ee.rsp oracle-18c-ee.rsp
ADD install/netca.rsp netca.rsp
ADD install/dbca_18c.rsp dbca_18c.rsp
ADD install/gosu gosu
ADD install/post_install.sh post_install.sh

RUN /oracle_18c_install_docker.sh
