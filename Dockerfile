FROM php:8.1-alpine

RUN docker-php-ext-install \
    bcmath \
    exif \
    mysqli \
    pdo_mysql

# Install AWS CLI.
RUN apk -v --update add \
    groff \
    less \
    python3 \
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
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-install -j${NPROC} gd \
    && apk del --no-cache freetype-dev libjpeg-turbo-dev libpng-dev

# Install Xdebug extension.
RUN apk add --no-cache \
    autoconf \
    gcc \
    g++ \
    make \
    && pecl install xdebug-3.1.5 \
    && docker-php-ext-enable xdebug

# Install Zip.
RUN apk add --no-cache \
    libzip-dev \
    && docker-php-ext-install \
    zip

CMD ["php", "-a"]
