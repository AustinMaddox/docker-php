FROM php:7.2-alpine

RUN docker-php-ext-install \
    bcmath \
    exif \
    mbstring \
    mysqli \
    pdo_mysql

# Install AWS CLI.
RUN apk -v --update add \
    groff \
    less \
    python \
    py-pip \
    && pip install --upgrade awscli python-magic \
    && apk -v --purge del py-pip \
    && rm /var/cache/apk/*

# Install Composer.
RUN apk add --no-cache \
    git

RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini"

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /.composer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

ENV GIT_COMMITTER_NAME php-cli
ENV GIT_COMMITTER_EMAIL php-cli@localhost

# Install GD library.
RUN apk add --no-cache \
    freetype \
    freetype-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libpng \
    libpng-dev \
    && docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-install -j${NPROC} gd \
    && apk del --no-cache freetype-dev libjpeg-turbo-dev libpng-dev

# Install Xdebug extension.
RUN apk add --no-cache \
    autoconf \
    gcc \
    g++ \
    make \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install Zip.
RUN apk add --no-cache \
    zlib-dev \
    && docker-php-ext-install \
    zip

# Install dumb-init.
RUN apk add --no-cache \
    dumb-init --repository http://dl-cdn.alpinelinux.org/alpine/v3.5/community/

# Runs "/usr/bin/dumb-init -- /my/script --with --args"
ENTRYPOINT ["/usr/bin/dumb-init", "--", "docker-php-entrypoint"]

CMD ["php", "-a"]
