# PowerShell script to set up Django project using cookiecutter-django

param (
    [string]$ProjectName = "{{ cookiecutter.project_name }}",
    [string]$ProjectSlug = "{{ cookiecutter.project_slug }}",
    [string]$AuthorName = "{{ cookiecutter.author_name }}",
    [string]$AuthorEmail = "{{ cookiecutter.author_email }}"
)

# Check if Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python is not installed. Please install Python 3.9+ and try again."
    exit 1
}

# Check if pip is installed
if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Error "pip is not installed. Please install pip and try again."
    exit 1
}

# Install cookiecutter if not already installed
if (-not (Get-Command cookiecutter -ErrorAction SilentlyContinue)) {
    Write-Host "Installing cookiecutter..."
    pip install cookiecutter
}

# Create a temporary JSON file with the cookiecutter configuration
$cookiecutterConfig = @{
    "project_name" = $ProjectName
    "project_slug" = $ProjectSlug
    "description" = "{{ cookiecutter.project_description }}"
    "author_name" = $AuthorName
    "author_email" = $AuthorEmail
    "domain_name" = "example.com"
    "email" = $AuthorEmail
    "version" = "0.1.0"
    "timezone" = "UTC"
    "use_whitenoise" = "y"
    "use_celery" = "y"
    "use_mailpit" = "y"
    "use_sentry" = "y"
    "use_pycharm" = "n"
    "windows" = "y"
    "use_docker" = "y"
    "postgresql_version" = "14"
    "cloud_provider" = "AWS"
    "mail_service" = "Mailgun"
    "use_async" = "y"
    "use_drf" = "y"
} | ConvertTo-Json

$configPath = "cookiecutter_config.json"
$cookiecutterConfig | Out-File -FilePath $configPath

try {
    # Run cookiecutter with the config file
    Write-Host "Setting up Django project..."
    cookiecutter gh:cookiecutter/cookiecutter-django --no-input --config-file $configPath --output-dir ..

    # Move files from the created directory to the current directory
    Get-ChildItem -Path "../$ProjectSlug" -Recurse | Move-Item -Destination . -Force
    Remove-Item "../$ProjectSlug" -Recurse -Force

    Write-Host "Django project setup complete!"
    Write-Host "Next steps:"
    Write-Host "1. Create and activate a virtual environment"
    Write-Host "2. Install dependencies: pip install -r requirements/local.txt"
    Write-Host "3. Set up your database"
    Write-Host "4. Run migrations: python manage.py migrate"
} finally {
    # Clean up the temporary config file
    Remove-Item $configPath -ErrorAction SilentlyContinue
}
