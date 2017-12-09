FROM nginx:latest

WORKDIR /opt/project
ENV TERM=xterm

RUN apt-get update
RUN apt-get install -y vim mc

ADD ./container /etc/containername

RUN usermod -u 1000 www-data
