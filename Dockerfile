FROM mirror.gcr.io/library/php:8.2-apache
# build-time env seeded from .env.example
ENV APP_KEY=SomeRandomString
ENV APP_URL=nexlayer-placeholder
ENV DB_DATABASE=database_database
ENV DB_HOST=localhost
ENV DB_PASSWORD=database_user_password
ENV DB_USERNAME=database_username
ENV MAIL_DRIVER=smtp
ENV MAIL_ENCRYPTION=null
ENV MAIL_FROM=nexlayer-placeholder
ENV MAIL_FROM_NAME=BookStack
ENV MAIL_HOST=localhost
ENV MAIL_PASSWORD=null
ENV MAIL_PORT=587
ENV MAIL_USERNAME=null
ENV STORAGE_TYPE=local

# Install essential system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    unzip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
# Using -j1 to reduce memory pressure and avoid runner crashes (OOM)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j1 gd pdo_mysql zip intl

# Install Composer
COPY --from=mirror.gcr.io/library/composer:latest /usr/bin/composer /usr/bin/composer

# Install Node.js (using a fixed version via nodesource)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

WORKDIR /var/www/html
COPY . .

# Install Composer dependencies
# Using --no-scripts to prevent any artisan commands from running during build
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Install NPM dependencies and build assets
# BookStack requires these for the UI to function
RUN npm install --legacy-peer-deps && npm run production

# Set permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public/uploads

# Configure Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -i 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

EXPOSE 80
ENV PORT=80
ENV HOSTNAME=0.0.0.0

CMD ["apache2-foreground"]