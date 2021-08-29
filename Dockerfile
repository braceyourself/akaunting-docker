FROM akaunting/akaunting:2-fpm

ARG WWWUSER=1000
ARG WWWGROUP=1000


ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apt-get update && apt-get install -y \
    git \
    iputils-ping

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd xdebug

RUN echo 'alias ls="ls -la --color=auto" >> /root/.bashrc'
RUN echo 'alias artisan="/usr/bin/php artisan" >> /root/.bashrc'


RUN groupmod -g $WWWGROUP www-data \
    && usermod -u $WWWUSER www-data \
    && chown www-data:www-data /var/www