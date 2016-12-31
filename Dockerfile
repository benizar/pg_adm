FROM postgres:9.6
MAINTAINER Benito Zaragozí <benizar@gmail.com>


##############
# Installation
##############

RUN apt-get update --fix-missing -y
RUN apt-get install -y build-essential checkinstall apt-utils
RUN apt-get install -y postgresql-server-dev-$PG_MAJOR

################
# Install pg_adm
################
WORKDIR /install-ext

ADD doc doc/
ADD sql sql/
ADD test test/
ADD makefile makefile
ADD META.json META.json
ADD pg_adm.control pg_adm.control

RUN make
RUN make install


WORKDIR /
RUN rm -rf /install-ext

ADD init-db.sh /docker-entrypoint-initdb.d/init-db.sh


