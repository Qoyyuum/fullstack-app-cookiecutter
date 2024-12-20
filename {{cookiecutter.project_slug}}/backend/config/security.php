{% if cookiecutter.tech_choice.separate.backend == "laravel" %}
<?php

return [
    {% if cookiecutter.api_security == "jwt" %}
    'jwt' => [
        'secret' => env('JWT_SECRET', '{{ cookiecutter.api_security.jwt.secret_key }}'),
        'refresh_secret' => env('JWT_REFRESH_SECRET', '{{ cookiecutter.api_security.jwt.refresh_secret_key }}'),
        'ttl' => env('JWT_TTL', '{{ cookiecutter.api_security.jwt.token_expiry }}'),
        'refresh_ttl' => env('JWT_REFRESH_TTL', '{{ cookiecutter.api_security.jwt.refresh_token_expiry }}'),
        'algo' => 'HS256',
    ],
    {% endif %}

    {% if cookiecutter.api_security == "api_key" %}
    'api_keys' => [
        'rotation_period' => env('API_KEY_ROTATION_PERIOD', '{{ cookiecutter.api_security.key_rotation_period }}'),
        'store' => env('API_KEY_STORE', 'database'), // options: database, redis
        'rate_limit' => [
            'enabled' => {{ cookiecutter.api_security.rate_limiting|lower }},
            'attempts' => env('API_RATE_LIMIT_ATTEMPTS', 60),
            'decay_minutes' => env('API_RATE_LIMIT_DECAY_MINUTES', 1),
        ],
    ],
    {% endif %}

    {% if cookiecutter.api_security == "oauth2" %}
    'oauth2' => [
        'providers' => {{ cookiecutter.api_security.oauth2.providers|tojson }},
        'pkce' => [
            'enabled' => {{ cookiecutter.api_security.pkce_required|lower }},
            'challenge_method' => 'S256',
        ],
        'state_param' => {{ cookiecutter.api_security.use_state_param|lower }},
    ],
    {% endif %}

    'cors' => [
        'allowed_origins' => [env('FRONTEND_URL', 'http://localhost:3000')],
        'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        'allowed_headers' => ['Content-Type', 'Authorization', 'X-API-Key'],
        'exposed_headers' => [],
        'max_age' => 0,
        'supports_credentials' => true,
    ],

    'secure_headers' => [
        'x-frame-options' => 'DENY',
        'x-xss-protection' => '1; mode=block',
        'x-content-type-options' => 'nosniff',
        'referrer-policy' => 'strict-origin-when-cross-origin',
        'content-security-policy' => "default-src 'self'",
        'strict-transport-security' => 'max-age=31536000; includeSubDomains',
    ],
];
{% endif %}
