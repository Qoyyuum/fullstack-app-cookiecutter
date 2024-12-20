{% if cookiecutter.tech_choice.separate.backend in ["nextjs", "nuxtjs", "quasar_ssr"] %}
import { verifyToken, validateApiKey, verifyOAuthToken } from '../config/security';

export const authMiddleware = async (req, res, next) => {
  try {
    {% if cookiecutter.api_security == "jwt" %}
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ message: 'No token provided' });
    }

    const decoded = verifyToken(token);
    req.user = decoded;
    {% endif %}

    {% if cookiecutter.api_security == "api_key" %}
    const apiKey = req.headers['x-api-key'];
    if (!apiKey || !validateApiKey(apiKey)) {
      return res.status(401).json({ message: 'Invalid API key' });
    }
    {% endif %}

    {% if cookiecutter.api_security == "oauth2" %}
    const token = req.headers.authorization?.split(' ')[1];
    const provider = req.headers['x-oauth-provider'];
    
    if (!token || !provider) {
      return res.status(401).json({ message: 'Invalid authentication' });
    }

    const userData = await verifyOAuthToken(token, provider);
    req.user = userData;
    {% endif %}

    next();
  } catch (error) {
    res.status(401).json({ message: 'Authentication failed', error: error.message });
  }
};
{% endif %}
