FROM percona:5.7

WORKDIR /opt/project
ENV TERM=xterm

RUN apt-get update
RUN apt-get install -y vim mc sqlite3 libsqlite3-dev curl

ADD etc/container /etc/containername

RUN usermod -u 1000 www-data

