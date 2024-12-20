#!/bin/bash

# Exit on error
set -e

echo "Setting up {{ cookiecutter.project_name }}..."

{% if cookiecutter.architecture_type == "separate" %}
# Install frontend dependencies
cd frontend
{% if cookiecutter.tech_choice.separate.frontend == "react" %}
npm install
{% elif cookiecutter.tech_choice.separate.frontend == "vue" %}
npm install
{% elif cookiecutter.tech_choice.separate.frontend == "quasar" %}
npm install @quasar/cli -g
npm install
{% elif cookiecutter.tech_choice.separate.frontend == "flutter" %}
flutter pub get
{% elif cookiecutter.tech_choice.separate.frontend == "hono" %}
npm install
{% endif %}

# Install backend dependencies
cd ../backend
{% if cookiecutter.tech_choice.separate.backend == "laravel" %}
composer install
composer require firebase/php-jwt
composer require league/oauth2-client
php artisan key:generate
{% if cookiecutter.api_security == "jwt" %}
php artisan vendor:publish --provider="PHPOpenSourceSaver\JWTAuth\Providers\LaravelServiceProvider"
{% endif %}
{% elif cookiecutter.tech_choice.separate.backend == "nextjs" %}
npm install
npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
npm install google-auth-library @auth0/nextjs-auth0
{% endif %}
{% elif cookiecutter.tech_choice.separate.backend == "nuxtjs" %}
npm install
npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
npm install @nuxtjs/auth-next @nuxtjs/axios
{% endif %}
{% elif cookiecutter.tech_choice.separate.backend == "quasar_ssr" %}
npm install @quasar/cli -g
npm install
npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
npm install @quasar/extras oauth2-client
{% endif %}
{% endif %}

# Generate security keys and certificates if needed
{% if cookiecutter.api_security == "jwt" %}
if [ ! -f .env ]; then
    echo "JWT_SECRET={{ cookiecutter.api_security.jwt.secret_key }}" >> .env
    echo "JWT_REFRESH_SECRET={{ cookiecutter.api_security.jwt.refresh_secret_key }}" >> .env
fi
{% endif %}

{% else %}
# Monolithic app setup with security dependencies
{% if cookiecutter.tech_choice.monolithic == "nextjs" %}
npm install
npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
npm install google-auth-library @auth0/nextjs-auth0
{% endif %}
{% elif cookiecutter.tech_choice.monolithic == "nuxtjs" %}
npm install
npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
npm install @nuxtjs/auth-next @nuxtjs/axios
{% endif %}
{% elif cookiecutter.tech_choice.monolithic == "quasar" %}
npm install @quasar/cli -g
npm install
npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
npm install @quasar/extras oauth2-client
{% endif %}
{% elif cookiecutter.tech_choice.monolithic == "laravel" %}
composer install
composer require firebase/php-jwt
composer require league/oauth2-client
php artisan key:generate
{% if cookiecutter.api_security == "jwt" %}
php artisan vendor:publish --provider="PHPOpenSourceSaver\JWTAuth\Providers\LaravelServiceProvider"
{% endif %}
{% endif %}
{% endif %}

{% if cookiecutter.repository_setup == "monorepo" %}
# Initialize git submodules
git submodule init
git submodule update
{% endif %}

# Build Docker containers if needed
if [ -f "docker-compose.yml" ]; then
    docker-compose build
fi

echo "Setup complete! Check the README.md for next steps and development instructions."
