FROM percona:5.7

WORKDIR /application
ENV TERM=xterm

RUN apt-get update
RUN apt-get install -y mc sqlite3 libsqlite3-dev

ADD ./container /etc/containername

RUN usermod -u 1000 www-data

