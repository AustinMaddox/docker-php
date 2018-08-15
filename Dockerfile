FROM php:7.1-alpine

# Install Xdebug extension.
RUN apk add --no-cache \
    autoconf \
    gcc \
    g++ \
    make \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install dumb-init.
RUN apk add --no-cache \
    dumb-init --repository http://dl-cdn.alpinelinux.org/alpine/v3.5/community/

# Install Composer.
RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini"
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

ENV GIT_COMMITTER_NAME php-cli
ENV GIT_COMMITTER_EMAIL php-cli@localhost

# Runs "/usr/bin/dumb-init -- /my/script --with --args"
ENTRYPOINT ["/usr/bin/dumb-init", "--", "docker-php-entrypoint"]

CMD ["php", "-a"]
