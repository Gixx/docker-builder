FROM php:7.1-fpm

WORKDIR /opt/project
ENV TERM=xterm

RUN apt-get update
RUN apt-get install -y git mc libmcrypt-dev sqlite3 libsqlite3-dev libicu-dev zlib1g-dev g++

RUN curl -L -o /tmp/xdebug.tar.gz https://github.com/xdebug/xdebug/archive/XDEBUG_2_5_0.tar.gz
RUN tar xfz /tmp/xdebug.tar.gz
RUN rm -r /tmp/xdebug.tar.gz
RUN mkdir -p /usr/src/php/ext
RUN mv ./xdebug-XDEBUG_2_5_0 /usr/src/php/ext/xdebug

RUN docker-php-ext-configure intl
RUN docker-php-ext-configure xdebug
RUN docker-php-ext-install intl mcrypt pdo_mysql pdo_sqlite xdebug bcmath gettext php-gettext

RUN curl -L -o /usr/local/bin/composer https://getcomposer.org/composer.phar
RUN chmod +x /usr/local/bin/composer

ADD ./www.conf /usr/local/etc/php-fpm.d/www.conf
ADD ./container /etc/containername

RUN usermod -u 1000 www-data


