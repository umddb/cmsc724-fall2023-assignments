FROM ubuntu:jammy
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt install -y python3-pip python3-dev postgresql postgresql-contrib libpq-dev jupyter-notebook vim openjdk-8-jdk 
RUN apt install -y sudo curl systemctl gnupg
RUN pip3 install jupyter ipython-sql psycopg2 flask flask-restful flask_cors pymongo
RUN pip3 install nbconvert

ADD Assignment-0/smallRelationsInsertFile.sql Assignment-0/largeRelationsInsertFile.sql Assignment-0/DDL.sql Assignment-0/zips.json /datatemp/
ADD Assignment-1/populate-sn.sql /datatemp/
ADD Assignment-2/sample_analytics /datatemp/
#ADD Assignment-4 /datatemp/Assignment-4

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
    psql --command "alter user root with superuser;"



#    createdb tpch &&\
#    cd /datatemp/Assignment-4 &&\
#    psql -f tpch/tpch-load.sql tpch &&\
#    createdb sn_med &&\
#    psql --command "\i /datatemp/Assignment-4/populate_sn_med.sql;" sn_med  &&\


USER root

RUN curl -fsSL  https://pgp.mongodb.com/server-7.0.asc |  sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor &&\
        echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list &&\
        apt-get update &&\
        apt-get install -y mongodb-org
## curl -O http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb &&\
## dpkg -i ./libssl1.1_1.1.1f-1ubuntu2_amd64.deb &&\
## apt install -y mongodb-org 

RUN systemctl enable mongod
RUN (/usr/bin/mongod --config /etc/mongod.conf &) &&\
mongoimport --db "analytics" --collection "customers" /datatemp/customers.json  &&\
mongoimport --db "analytics" --collection "accounts" /datatemp/accounts.json  &&\
mongoimport --db "analytics" --collection "transactions" /datatemp/transactions.json  &&\
mongoimport --db "zips" --collection "examples" /datatemp/zips.json

ENV SPARKHOME=/spark/

ENTRYPOINT service postgresql start &&\ 
        (/usr/bin/mongod --config /etc/mongod.conf &) &&\
        (jupyter-notebook --port=8888 --allow-root --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir='/data' --NotebookApp.token='' 2>/dev/null &) &&\ 
        /bin/bash

#ENTRYPOINT service postgresql start && /bin/bash
##&& (/usr/bin/mongod --config /etc/mongod.conf &) &&\ 
##mongoimport --db "analytics" --collection "customers" /data/Assignment-2/sample_analytics/customers.json &&\
##mongoimport --db "analytics" --collection "accounts" /data/Assignment-2/sample_analytics/accounts.json &&\
##mongoimport --db "analytics" --collection "transactions" /data/Assignment-2/sample_analytics/transactions.json &&\
###/bin/bash
