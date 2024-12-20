{% if cookiecutter.tech_choice.separate.backend == "laravel" %}
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class ApiAuthentication
{
    public function handle(Request $request, Closure $next)
    {
        try {
            {% if cookiecutter.api_security == "jwt" %}
            $token = $request->bearerToken();
            if (!$token) {
                return response()->json(['message' => 'No token provided'], 401);
            }

            $decoded = JWT::decode($token, new Key(config('security.jwt.secret'), config('security.jwt.algo')));
            $request->user = $decoded;
            {% endif %}

            {% if cookiecutter.api_security == "api_key" %}
            $apiKey = $request->header('X-API-Key');
            if (!$apiKey || !$this->validateApiKey($apiKey)) {
                return response()->json(['message' => 'Invalid API key'], 401);
            }
            {% endif %}

            {% if cookiecutter.api_security == "oauth2" %}
            $token = $request->bearerToken();
            $provider = $request->header('X-OAuth-Provider');
            
            if (!$token || !$provider) {
                return response()->json(['message' => 'Invalid authentication'], 401);
            }

            $userData = $this->verifyOAuthToken($token, $provider);
            $request->user = $userData;
            {% endif %}

            return $next($request);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Authentication failed', 'error' => $e->getMessage()], 401);
        }
    }

    {% if cookiecutter.api_security == "api_key" %}
    protected function validateApiKey($key)
    {
        // Implement API key validation logic using database or cache
        return \App\Models\ApiKey::where('key', $key)
            ->where('expires_at', '>', now())
            ->exists();
    }
    {% endif %}

    {% if cookiecutter.api_security == "oauth2" %}
    protected function verifyOAuthToken($token, $provider)
    {
        // Implement OAuth token verification logic
        $client = new \League\OAuth2\Client\Provider\GenericProvider([
            'clientId' => config("services.{$provider}.client_id"),
            'clientSecret' => config("services.{$provider}.client_secret"),
            'redirectUri' => config("services.{$provider}.redirect"),
            'urlAuthorize' => config("services.{$provider}.url_authorize"),
            'urlAccessToken' => config("services.{$provider}.url_access_token"),
            'urlResourceOwnerDetails' => config("services.{$provider}.url_resource_owner_details"),
        ]);

        return $client->getResourceOwner($token);
    }
    {% endif %}
}
{% endif %}
