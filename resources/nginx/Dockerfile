FROM percona:5.6

WORKDIR /application
ENV TERM=xterm

RUN mkdir -p /etc/nginx/ssl
RUN sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/%vm.domain%.key -out /etc/nginx/ssl/%vm.domain%.crt

ADD ./container /etc/containername

RUN usermod -u 1000 www-data
