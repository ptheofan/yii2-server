FROM php:7.4-fpm

ARG XDEBUG_SERVER_NAME=docker

## OS dependencies
RUN apt-get update && \
    apt-get -y install \
        gnupg2 \
        nginx \
        redis \
        supervisor && \
    apt-key update && \
    apt-get update && \
    apt-get -y install \
            g++ \
            git \
            curl \
            imagemagick \
            libcurl3-dev \
            libicu-dev \
            libfreetype6-dev \
            libjpeg-dev \
            libjpeg62-turbo-dev \
            libonig-dev \
            libmagickwand-dev \
            libpq-dev \
            libpng-dev \
            libxml2-dev \
            libzip-dev \
            zlib1g-dev \
            default-mysql-client \
            openssh-client \
            nano \
            unzip \
            libcurl4-openssl-dev \
            libssl-dev \
        --no-install-recommends && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## PHP Exts
RUN docker-php-ext-configure bcmath && \
    docker-php-ext-install \
        soap \
        zip \
        curl \
        bcmath \
        exif \
        gd \
        iconv \
        intl \
        mbstring \
        opcache \
        pdo_mysql \
        pdo_pgsql

# PECL; imagick
RUN printf "\n" | pecl install imagick; \
    docker-php-ext-enable imagick

# PECL; xdebug
RUN printf "\n" | pecl install xdebug; \
    docker-php-ext-enable xdebug

# PECL; igbinary
RUN printf "\n" | pecl install igbinary; \
    docker-php-ext-enable igbinary

# PECL; Redis (w/ igbinary) (see https://github.com/phpredis/phpredis/issues/1176#issuecomment-739509358)
RUN pecl install -D 'enable-redis-igbinary="yes" enable-redis-lzf="no" enable-redis-zstd="no"' redis; \
    docker-php-ext-enable redis

# PECL; mongo
RUN printf "\n" | pecl install mongodb; \
    docker-php-ext-enable mongodb

# default php config folder is going to be replaced
# make a copy to have a place for reference when needed
RUN cp -r /usr/local/etc/php /usr/local/etc/php.bak

# Environment settings
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    PHP_USER_ID=33 \
    PHP_ENABLE_XDEBUG=0 \
    PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
    TERM=linux

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# Install Yii framework bash autocompletion
RUN curl -L https://raw.githubusercontent.com/yiisoft/yii2/master/contrib/completion/bash/yii \
        -o /etc/bash_completion.d/yii

ENV PATH="/usr/local/bin:/usr/bin:${PATH}"
ENV PHP_IDE_CONFIG="serverName=${XDEBUG_SERVER_NAME}"
ENV XDEBUG_SESSION="${XDEBUG_SERVER_NAME}"

COPY root/ /
RUN mkdir -p /var/log/putin; chown -R www-data: /var/log/putin

EXPOSE 80
WORKDIR /app

COPY entry.sh /entry
RUN chmod +x /entry

# ENTRYPOINT [ "/usr/bin/entry" ]
# CMD ["/usr/bin/supervisord"]
CMD ["/entry"]