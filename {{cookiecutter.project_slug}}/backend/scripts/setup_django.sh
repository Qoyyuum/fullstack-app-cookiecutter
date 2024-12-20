#!/bin/bash

# Script to set up Django project using cookiecutter-django

PROJECT_NAME="{{ cookiecutter.project_name }}"
PROJECT_SLUG="{{ cookiecutter.project_slug }}"
AUTHOR_NAME="{{ cookiecutter.author_name }}"
AUTHOR_EMAIL="{{ cookiecutter.author_email }}"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python is not installed. Please install Python 3.9+ and try again."
    exit 1
fi

# Check if pip is installed
if ! command -v pip &> /dev/null; then
    echo "pip is not installed. Please install pip and try again."
    exit 1
fi

# Install cookiecutter if not already installed
if ! command -v cookiecutter &> /dev/null; then
    echo "Installing cookiecutter..."
    pip install cookiecutter
fi

# Create a temporary JSON file with the cookiecutter configuration
cat > cookiecutter_config.json << EOL
{
    "project_name": "${PROJECT_NAME}",
    "project_slug": "${PROJECT_SLUG}",
    "description": "{{ cookiecutter.project_description }}",
    "author_name": "${AUTHOR_NAME}",
    "author_email": "${AUTHOR_EMAIL}",
    "domain_name": "example.com",
    "email": "${AUTHOR_EMAIL}",
    "version": "0.1.0",
    "timezone": "UTC",
    "use_whitenoise": "y",
    "use_celery": "y",
    "use_mailpit": "y",
    "use_sentry": "y",
    "use_pycharm": "n",
    "windows": "n",
    "use_docker": "y",
    "postgresql_version": "14",
    "cloud_provider": "AWS",
    "mail_service": "Mailgun",
    "use_async": "y",
    "use_drf": "y"
}
EOL

# Run cookiecutter with the config file
echo "Setting up Django project..."
cookiecutter gh:cookiecutter/cookiecutter-django --no-input --config-file cookiecutter_config.json --output-dir ..

# Move files from the created directory to the current directory
mv "../${PROJECT_SLUG}"/* .
mv "../${PROJECT_SLUG}"/.[!.]* . 2>/dev/null || true
rm -rf "../${PROJECT_SLUG}"

# Clean up the temporary config file
rm cookiecutter_config.json

echo "Django project setup complete!"
echo "Next steps:"
echo "1. Create and activate a virtual environment"
echo "2. Install dependencies: pip install -r requirements/local.txt"
echo "3. Set up your database"
echo "4. Run migrations: python manage.py migrate"
