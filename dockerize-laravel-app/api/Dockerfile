FROM php:8.2-fpm

WORKDIR /usr/src

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    supervisor

RUN apt-get clean && rm -rf /var/lib/apt/lists!/
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip
RUN pecl install redis
COPY --from=composer:2.5.8 /usr/bin/composer /usr/bin/composer

COPY ./api .
RUN composer install

COPY ./deployment/config/php-fpm/php.ini /usr/local/etc/php/conf.d/php.ini
COPY ./deployment/config/php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf
