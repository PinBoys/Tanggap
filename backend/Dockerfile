FROM php:8.2-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libxml2-dev \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_pgsql \
    pgsql \
    bcmath \
    zip \
    gd \
    intl \
    opcache \
    && a2enmod rewrite headers \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy Laravel source
COPY . .

# Install production dependencies
RUN COMPOSER_PROCESS_TIMEOUT=600 composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --prefer-dist \
    --no-progress

# Configure Apache public directory
RUN sed -ri 's!/var/www/html!/var/www/html/public!g' \
    /etc/apache2/sites-available/000-default.conf \
    /etc/apache2/apache2.conf

# Configure Laravel storage permissions and symbolic link
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && php artisan storage:link \
    && chown -h www-data:www-data public/storageRUN composer install RUN composer install 

# Configure Apache to use EthioDeploy PORT
RUN printf '#!/bin/sh\nset -e\nsed -i "s/Listen 80/Listen ${PORT:-3000}/" /etc/apache2/ports.conf\nsed -i "s/:80>/:${PORT:-3000}>/" /etc/apache2/sites-available/000-default.conf\nexec apache2-foreground\n' \
    > /usr/local/bin/start-apache \
    && chmod +x /usr/local/bin/start-apache

EXPOSE 3000

CMD ["/usr/local/bin/start-apache"]
