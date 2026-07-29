# syntax=docker/dockerfile:1

ARG PHP_VERSION=8.3

FROM composer:2 AS composer

FROM php:${PHP_VERSION}-fpm-alpine AS php_base
RUN apk add --no-cache \
        bash \
        icu-dev \
        libzip-dev \
        oniguruma-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        mysql-client \
        sqlite-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        pdo_mysql \
        pdo_sqlite \
        bcmath \
        intl \
        zip \
        opcache \
        gd
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY docker/php/php.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
WORKDIR /var/www/html
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 9000
CMD ["php-fpm"]

# ---------- development ----------
FROM php_base AS dev
RUN apk add --no-cache $PHPIZE_DEPS linux-headers nodejs npm \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug
COPY docker/php/xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini
COPY docker/php/php-dev.ini /usr/local/etc/php/conf.d/zz-dev.ini

# ---------- production app (php-fpm) ----------
FROM php_base AS prod
COPY docker/php/php-prod.ini /usr/local/etc/php/conf.d/zz-prod.ini
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction
COPY . .
RUN composer dump-autoload --optimize --no-dev
RUN apk add --no-cache nodejs npm \
    && cp .env.example .env \
    && php artisan key:generate --ansi \
    && npm ci \
    && npm run build \
    && rm -rf .env node_modules \
    && apk del nodejs npm
RUN chown -R www-data:www-data storage bootstrap/cache

# ---------- production web server (nginx) ----------
FROM nginx:1.27-alpine AS prod_nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=prod /var/www/html/public /var/www/html/public
