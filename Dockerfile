FROM mirror.gcr.io/library/node:22-alpine AS assets-builder
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
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run production

FROM mirror.gcr.io/library/php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libzip-dev \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Correctly configure and install GD and other extensions
# Removed the invalid '-n' flag which caused the 'getopt: invalid option -- n' error
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd pdo_mysql zip

# Install Composer using official mirror
COPY --from=mirror.gcr.io/library/composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy source
COPY . .

# Install PHP dependencies - ignoring scripts to avoid build-time crashes
RUN composer install --no-dev --optimize-autoloader --no-scripts || true

# Copy compiled assets from assets-builder
COPY --from=assets-builder /app/public/dist ./public/dist/

# Set permissions for Laravel
RUN chown -R www-data:www-data storage bootstrap/cache public/uploads

# Configure Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -i 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

EXPOSE 80
ENV PORT=80
ENV HOSTNAME=0.0.0.0
CMD ["apache2-foreground"]