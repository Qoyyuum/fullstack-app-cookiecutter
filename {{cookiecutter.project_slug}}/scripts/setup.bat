@echo off
echo Setting up {{ cookiecutter.project_name }}...

{% if cookiecutter.architecture_type == "separate" %}
REM Install frontend dependencies
cd frontend
{% if cookiecutter.tech_choice.separate.frontend == "react" %}
call npm install
{% elif cookiecutter.tech_choice.separate.frontend == "vue" %}
call npm install
{% elif cookiecutter.tech_choice.separate.frontend == "quasar" %}
call npm install @quasar/cli -g
call npm install
{% elif cookiecutter.tech_choice.separate.frontend == "flutter" %}
call flutter pub get
{% elif cookiecutter.tech_choice.separate.frontend == "hono" %}
call npm install
{% endif %}

REM Install backend dependencies
cd ..\backend
{% if cookiecutter.tech_choice.separate.backend == "laravel" %}
call composer install
call composer require firebase/php-jwt
call composer require league/oauth2-client
call php artisan key:generate
{% if cookiecutter.api_security == "jwt" %}
call php artisan vendor:publish --provider="PHPOpenSourceSaver\JWTAuth\Providers\LaravelServiceProvider"
{% endif %}
{% elif cookiecutter.tech_choice.separate.backend == "nextjs" %}
call npm install
call npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
call npm install google-auth-library @auth0/nextjs-auth0
{% endif %}
{% elif cookiecutter.tech_choice.separate.backend == "nuxtjs" %}
call npm install
call npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
call npm install @nuxtjs/auth-next @nuxtjs/axios
{% endif %}
{% elif cookiecutter.tech_choice.separate.backend == "quasar_ssr" %}
call npm install @quasar/cli -g
call npm install
call npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
call npm install @quasar/extras oauth2-client
{% endif %}
{% endif %}

REM Generate security keys and certificates if needed
{% if cookiecutter.api_security == "jwt" %}
if not exist .env (
    echo JWT_SECRET={{ cookiecutter.api_security.jwt.secret_key }} >> .env
    echo JWT_REFRESH_SECRET={{ cookiecutter.api_security.jwt.refresh_secret_key }} >> .env
)
{% endif %}

{% else %}
REM Monolithic app setup with security dependencies
{% if cookiecutter.tech_choice.monolithic == "nextjs" %}
call npm install
call npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
call npm install google-auth-library @auth0/nextjs-auth0
{% endif %}
{% elif cookiecutter.tech_choice.monolithic == "nuxtjs" %}
call npm install
call npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
call npm install @nuxtjs/auth-next @nuxtjs/axios
{% endif %}
{% elif cookiecutter.tech_choice.monolithic == "quasar" %}
call npm install @quasar/cli -g
call npm install
call npm install jsonwebtoken express-rate-limit
{% if cookiecutter.api_security == "oauth2" %}
call npm install @quasar/extras oauth2-client
{% endif %}
{% elif cookiecutter.tech_choice.monolithic == "laravel" %}
call composer install
call composer require firebase/php-jwt
call composer require league/oauth2-client
call php artisan key:generate
{% if cookiecutter.api_security == "jwt" %}
call php artisan vendor:publish --provider="PHPOpenSourceSaver\JWTAuth\Providers\LaravelServiceProvider"
{% endif %}
{% endif %}
{% endif %}

{% if cookiecutter.repository_setup == "monorepo" %}
REM Initialize git submodules
git submodule init
git submodule update
{% endif %}

REM Build Docker containers if needed
if exist "docker-compose.yml" (
    docker-compose build
)

echo Setup complete! Check the README.md for next steps and development instructions.
