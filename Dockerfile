FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt install -y python3-pip python3-dev postgresql postgresql-contrib libpq-dev jupyter-notebook vim openjdk-8-jdk 
RUN apt install -y sudo curl systemctl
RUN pip3 install jupyter ipython-sql psycopg2 flask flask-restful flask_cors pymongo

ADD Assignment-0/smallRelationsInsertFile.sql Assignment-0/largeRelationsInsertFile.sql Assignment-0/DDL.sql /datatemp/
ADD Assignment-1/populate-sn.sql /datatemp/
ADD Assignment-2/sample_analytics /datatemp/
ADD Assignment-4 /datatemp/Assignment-4

EXPOSE 8888
EXPOSE 5432

#RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add - &&\
#echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list &&\
#apt update &&\
#apt install -y mongodb-org 

#RUN systemctl enable mongod
#RUN /usr/bin/mongod --config /etc/mongod.conf &
#RUN systemctl start mongod
### RUN mkdir /mongodata
### RUN mkdir /mongodata/db

USER postgres

RUN /etc/init.d/postgresql start &&\
    createdb university &&\
    psql --command "\i /datatemp/DDL.sql;" university &&\
    psql --command "\i /datatemp/smallRelationsInsertFile.sql;" university &&\
    psql --command "alter user postgres with password 'postgres';" university &&\
    psql --command "create user root;" university &&\
    psql --command "alter user root with password 'root';" university &&\
    createdb socialnetwork &&\
    psql --command "\i /datatemp/populate-sn.sql;" socialnetwork  &&\
    createdb sn_med &&\
    psql --command "\i /datatemp/Assignment-4/populate_sn_med.sql;" sn_med  &&\
    createdb tpch &&\
    cd /datatemp/Assignment-4 &&\
    psql -f tpch/tpch-load.sql tpch &&\
    psql --command "alter user root with superuser;"


USER root

ENTRYPOINT service postgresql start && /bin/bash
#&& (/usr/bin/mongod --config /etc/mongod.conf &) &&\ 
#mongoimport --db "analytics" --collection "customers" /data/Assignment-2/sample_analytics/customers.json &&\
#mongoimport --db "analytics" --collection "accounts" /data/Assignment-2/sample_analytics/accounts.json &&\
#mongoimport --db "analytics" --collection "transactions" /data/Assignment-2/sample_analytics/transactions.json &&\
#/bin/bash
