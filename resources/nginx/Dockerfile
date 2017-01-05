FROM nginx:latest

WORKDIR /application
ENV TERM=xterm

ADD ./container /etc/containername

RUN usermod -u 1000 www-data
