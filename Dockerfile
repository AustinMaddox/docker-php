FROM php:5.6-apache

MAINTAINER "Austin Maddox" <austin@maddoxbox.com>

RUN apt-get update

# Install Xdebug extension.
RUN apt-get install -y \
    autoconf \
    gcc \
    g++ \
    make \
    && pecl install xdebug-2.5.5 \
    && docker-php-ext-enable xdebug

# Set the "ServerName" directive globally to suppress this message... "Could not reliably determine the server's fully qualified domain name, using #.#.#.#."
COPY ./etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-available/fqdn.conf
RUN a2enconf fqdn

# Define the default virtual host.
COPY ./etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default \
	&& a2enmod rewrite

# If needed, add a custom php.ini configuration.
COPY ./usr/local/etc/php/php.ini /usr/local/etc/php/php.ini

# Cleanup
RUN apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
