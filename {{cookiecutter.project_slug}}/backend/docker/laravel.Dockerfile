# Use official PHP image as base
FROM php:8.2-fpm as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-scripts --no-autoloader --no-dev

# Copy application files
COPY . .

# Generate optimized autoload files
RUN composer dump-autoload --optimize

# Production stage
FROM php:8.2-fpm

# Install production dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy application from builder
COPY --from=builder /app /app

# Create storage directory and set permissions
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && chmod -R 775 storage \
    && chown -R www-data:www-data storage

# Install nginx
RUN apt-get update && apt-get install -y nginx

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Start PHP-FPM and nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
