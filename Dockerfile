FROM php:5.4-cli

ENV COMPOSER_MEMORY_LIMIT -1
ENV PHPREDIS_VERSION 4.3.0
ARG MEMCACHED_VERSION=2.2.0

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN  set -xe \
    && apt-get update \
    && apt-get install -y libmemcached-dev libzip-dev git \
    && pecl install memcached-${MEMCACHED_VERSION} \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip \
    && docker-php-ext-install pdo pdo_mysql \
    && docker-php-ext-install mbstring  \
    && ( \
        curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
        && tar xfz /tmp/redis.tar.gz \
        && rm -r /tmp/redis.tar.gz \
        && mkdir -p /usr/src/php/ext \
        && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
        && docker-php-ext-install redis \
    ) \
    && docker-php-ext-enable memcached \
    && rm -rf /var/lib/apt/lists/*
