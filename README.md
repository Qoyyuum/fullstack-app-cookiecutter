# Fullstack App Template

A comprehensive cookiecutter template for creating modern fullstack applications with business planning and deployment strategies included. This template follows the [Twelve-Factor App](https://12factor.net/) methodology for building software-as-a-service applications.

## Features

- Multiple frontend framework options (Vanilla NodeJS, Deno, HonoJS, React/React Native, Vue/Quasar, Flutter)
- Multiple backend framework options (Django, Laravel, NuxtJS, NextJS, Quasar SSR)
- Modern database solutions (Supabase, Neon, PlanetScale)
- Infrastructure as Code with OpenTofu/Terraform/Pulumi
- Cloudflare DNS and domain management
- Docker support
- CI/CD with GitHub Actions
- Comprehensive documentation templates
- Business planning templates
- Testing strategies
- Deployment guides

## 12-Factor App Implementation

This template adheres to the twelve-factor methodology:

1. **Codebase**: One codebase tracked in revision control, many deploys
2. **Dependencies**: Explicitly declare and isolate dependencies
3. **Config**: Store config in the environment
4. **Backing services**: Treat backing services as attached resources
5. **Build, release, run**: Strictly separate build and run stages
6. **Processes**: Execute the app as one or more stateless processes
7. **Port binding**: Export services via port binding
8. **Concurrency**: Scale out via the process model
9. **Disposability**: Maximize robustness with fast startup and graceful shutdown
10. **Dev/prod parity**: Keep development, staging, and production as similar as possible
11. **Logs**: Treat logs as event streams
12. **Admin processes**: Run admin/management tasks as one-off processes

## Requirements

- Python 3.7+
- Cookiecutter (`pip install cookiecutter`)
- Docker (optional)

## Usage

```bash
# Create a new project
cookiecutter gh:qoyyuum/fullstack-app-cookiecutter

# Answer the prompts to customize your project
```

## Environment Support

The template supports three environments:

- **Base**: Common configuration and setup shared across all environments
- **Local**: Development environment configuration
- **Production**: Production environment configuration

## Template Options

- `project_name`: Name of your project
- `environment`: Choose environment type (base/local/production)
- `architecture_type`: Monolithic or separate frontend/backend
- `tech_choice`: Framework selection
- `database`: Choice of modern database provider (Supabase/Neon/PlanetScale)
- `infrastructure_as_code`: IaC tool selection
- `deployment_platform`: Cloud provider selection
- `domain_management`: Cloudflare DNS configuration
- Various framework-specific addons

## Directory Structure

```
{{ cookiecutter.project_slug }}/
├── frontend/              # Frontend application (if separate)
├── backend/              # Backend application (if separate)
├── app/                  # Monolithic application (if monolithic)
├── infrastructure/       # IaC configurations
│   ├── opentofu/        # OpenTofu configurations
│   └── cloudflare/      # Cloudflare configurations
├── environments/        # Environment-specific configurations
│   ├── base/           # Base configuration
│   ├── local/          # Local development
│   └── production/     # Production setup
├── scripts/             # Setup and utility scripts
├── docs/                # Documentation
├── .github/             # GitHub Actions workflows
└── docker-compose.yml   # Docker composition

## License

This project is licensed under the MIT License.
