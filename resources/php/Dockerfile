FROM php:7.1-fpm

WORKDIR /opt/project
ENV TERM=xterm

# Update the package repository
RUN apt-get update
RUN apt-get -y --no-install-recommends install libicu-dev zlib1g-dev g++
RUN apt-get -y --no-install-recommends install sqlite3 libsqlite3-dev
RUN apt-get -y --no-install-recommends install vim mc zip unzip git
RUN apt-get -y --no-install-recommends install locales
RUN apt-get -y --no-install-recommends install libpng-dev
RUN apt-get -y --no-install-recommends install gettext php-gettext
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install xdebug in docker-compatible way
RUN curl -L -o /tmp/xdebug.tar.gz https://github.com/xdebug/xdebug/archive/XDEBUG_2_5_5.tar.gz
RUN tar xfz /tmp/xdebug.tar.gz
RUN rm -r /tmp/xdebug.tar.gz
RUN mkdir -p /usr/src/php/ext
RUN mv ./xdebug-XDEBUG_2_5_5 /usr/src/php/ext/xdebug

# Configure php
RUN docker-php-ext-configure intl
RUN docker-php-ext-configure xdebug
RUN docker-php-ext-configure gd
RUN docker-php-ext-install intl pdo_mysql pdo_sqlite xdebug bcmath  gettext gd mbstring zip

# Install composer globally
RUN curl -L -o /usr/local/bin/composer https://getcomposer.org/composer.phar
RUN chmod +x /usr/local/bin/composer

# Add git-bash
RUN git clone https://github.com/magicmonty/bash-git-prompt.git /root/.bash-git-prompt --depth=1

# Add pre-edited files
ADD etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf
ADD etc/container /etc/containername
ADD etc/locale.gen /etc/locale.gen
ADD etc/timezone /etc/timezone
ADD etc/default/locale /etc/default/locale
ADD root/.bashrc /root/.bashrc
ADD root/.gitconfig /root/.gitconfig

# Generate locales
RUN dpkg-reconfigure --frontend=noninteractive locales
RUN dpkg-reconfigure -f noninteractive tzdata
RUN locale-gen

RUN usermod -u 1000 www-data
