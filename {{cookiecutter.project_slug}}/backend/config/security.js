{% if cookiecutter.tech_choice.separate.backend in ["nextjs", "nuxtjs", "quasar_ssr"] %}
import jwt from 'jsonwebtoken';
import rateLimit from 'express-rate-limit';
import { OAuth2Client } from 'google-auth-library';

{% if cookiecutter.api_security == "jwt" %}
export const JWT_SECRET = process.env.JWT_SECRET || '{{ cookiecutter.api_security.jwt.secret_key }}';
export const REFRESH_TOKEN_SECRET = process.env.REFRESH_TOKEN_SECRET || '{{ cookiecutter.api_security.jwt.refresh_secret_key }}';
export const TOKEN_EXPIRY = '{{ cookiecutter.api_security.jwt.token_expiry }}';
export const REFRESH_TOKEN_EXPIRY = '{{ cookiecutter.api_security.jwt.refresh_token_expiry }}';

export const verifyToken = (token) => {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    throw new Error('Invalid token');
  }
};

export const generateTokens = (payload) => {
  const accessToken = jwt.sign(payload, JWT_SECRET, { expiresIn: TOKEN_EXPIRY });
  const refreshToken = jwt.sign(payload, REFRESH_TOKEN_SECRET, { expiresIn: REFRESH_TOKEN_EXPIRY });
  return { accessToken, refreshToken };
};
{% endif %}

{% if cookiecutter.api_security == "api_key" %}
export const API_KEYS = new Map();
export const KEY_ROTATION_PERIOD = '{{ cookiecutter.api_security.key_rotation_period }}';

export const validateApiKey = (apiKey) => {
  return API_KEYS.has(apiKey) && !isKeyExpired(apiKey);
};

export const generateApiKey = (clientId) => {
  const key = crypto.randomBytes(32).toString('hex');
  API_KEYS.set(key, {
    clientId,
    createdAt: new Date(),
    expiresAt: new Date(Date.now() + ms(KEY_ROTATION_PERIOD))
  });
  return key;
};
{% endif %}

{% if cookiecutter.api_security == "oauth2" %}
const oauthClients = {
  google: new OAuth2Client({
    clientId: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET
  }),
  // Add other OAuth providers here
};

export const verifyOAuthToken = async (token, provider) => {
  const client = oauthClients[provider];
  if (!client) throw new Error('Invalid OAuth provider');
  
  const ticket = await client.verifyIdToken({
    idToken: token,
    audience: process.env.GOOGLE_CLIENT_ID
  });
  
  return ticket.getPayload();
};
{% endif %}

// Rate limiting middleware
export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
{% endif %}
