#!/bin/sh
set -e

if [ "$APP_ENV" = "local" ]; then
    chmod -R ugo+rwX storage bootstrap/cache database
fi

if [ ! -f vendor/autoload.php ]; then
    composer install --no-interaction
fi

if [ ! -f .env ] && [ -f .env.example ]; then
    cp .env.example .env
fi

if ! grep -q '^APP_KEY=.\+' .env 2>/dev/null; then
    php artisan key:generate --ansi
fi

if [ "$APP_ENV" = "local" ] && [ -n "$DB_HOST" ]; then
    echo "Waiting for database at $DB_HOST:${DB_PORT:-3306}..."
    until php -r "new PDO('mysql:host=$DB_HOST;port=${DB_PORT:-3306}', '$DB_USERNAME', '$DB_PASSWORD');" 2>/dev/null; do
        sleep 1
    done
    php artisan migrate --force
fi

exec "$@"
