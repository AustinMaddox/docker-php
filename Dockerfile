FROM php:7.1-apache

MAINTAINER "Austin Maddox" <austin@maddoxbox.com>

RUN apt-get update

# Install and enable Zend OPcache.
RUN docker-php-ext-install \
    opcache \
    && docker-php-ext-enable \
    opcache

# Install Xdebug extension.
RUN apt-get install -y \
    autoconf \
    gcc \
    g++ \
    make \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# Set the "ServerName" directive globally to suppress this message... "Could not reliably determine the server's fully qualified domain name, using #.#.#.#."
COPY ./etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-available/fqdn.conf
RUN a2enconf fqdn

# Define the default virtual host.
COPY ./etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default \
	&& a2enmod deflate rewrite

# If needed, add any custom php.ini directives that will add/override the default configuration(s).
COPY ./usr/local/etc/php/php.ini /usr/local/etc/php/php.ini

# If needed, add any custom php.ini directives that will add/override the default configuration(s).
COPY ./usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Cleanup
RUN apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
