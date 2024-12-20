import os
import shutil
import subprocess
from cookiecutter.main import cookiecutter

def remove_dir_if_exists(path):
    if os.path.exists(path):
        shutil.rmtree(path)

def remove_file_if_exists(path):
    if os.path.exists(path):
        os.remove(path)

def setup_django_cookiecutter(output_dir, options):
    """Set up Django using cookiecutter-django"""
    cookiecutter(
        'https://github.com/cookiecutter/cookiecutter-django.git',
        no_input=True,
        extra_context=options,
        output_dir=output_dir
    )

def setup_django_project(output_dir):
    """Set up Django project using cookiecutter-django"""
    # Make scripts executable on Unix-like systems
    scripts_dir = os.path.join(output_dir, 'scripts')
    setup_script = os.path.join(scripts_dir, 'setup_django.sh')
    if os.name != 'nt':  # Unix-like systems
        os.chmod(setup_script, 0o755)
        subprocess.run(['./setup_django.sh'], cwd=scripts_dir, check=True)
    else:  # Windows
        subprocess.run(['powershell', '-ExecutionPolicy', 'Bypass', '-File', 'setup_django.ps1'], 
                      cwd=scripts_dir, check=True)

def setup_auth_provider(auth_choice, project_dir):
    """Set up authentication provider configurations"""
    auth_configs = {
        'supabase_auth': {
            'files': ['supabase.ts', 'auth.ts'],
            'env_vars': [
                'SUPABASE_URL=your_supabase_url',
                'SUPABASE_ANON_KEY=your_supabase_anon_key'
            ]
        },
        'clerk': {
            'files': ['clerk.ts', 'auth.ts'],
            'env_vars': [
                'CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key',
                'CLERK_SECRET_KEY=your_clerk_secret_key'
            ]
        },
        'twilio': {
            'files': ['twilio.ts', 'auth.ts'],
            'env_vars': [
                'TWILIO_ACCOUNT_SID=your_twilio_account_sid',
                'TWILIO_AUTH_TOKEN=your_twilio_auth_token',
                'TWILIO_SERVICE_SID=your_twilio_service_sid'
            ]
        },
        'keycloak': {
            'files': ['keycloak.ts', 'auth.ts'],
            'env_vars': [
                'KEYCLOAK_URL=your_keycloak_url',
                'KEYCLOAK_REALM=your_keycloak_realm',
                'KEYCLOAK_CLIENT_ID=your_keycloak_client_id',
                'KEYCLOAK_CLIENT_SECRET=your_keycloak_client_secret'
            ]
        }
    }

    auth_config = auth_configs.get(auth_choice)
    if auth_config:
        # Create auth directory
        auth_dir = os.path.join(project_dir, 'src', 'auth')
        os.makedirs(auth_dir, exist_ok=True)

        # Copy example files
        for file in auth_config['files']:
            src = os.path.join('auth_templates', auth_choice, file)
            dst = os.path.join(auth_dir, file)
            if os.path.exists(src):
                shutil.copy2(src, dst)

        # Add environment variables
        env_file = os.path.join(project_dir, '.env.example')
        with open(env_file, 'a') as f:
            f.write('\n# Authentication\n')
            for env_var in auth_config['env_vars']:
                f.write(f'{env_var}\n')

def setup_infrastructure_code(iac_choice, deployment_config):
    """Set up infrastructure as code based on deployment choices"""
    iac_configs = {
        'opentofu': {
            'extension': 'tf',
            'dir_structure': ['environments', 'modules']
        },
        'terraform': {
            'extension': 'tf',
            'dir_structure': ['environments', 'modules']
        },
        'pulumi': {
            'extension': 'ts',  # or based on language choice
            'dir_structure': ['environments', 'modules']
        }
    }

    iac_config = iac_configs.get(iac_choice['name'].lower())
    if not iac_config:
        return

    # Create base directory structure
    infra_dir = os.path.join('infrastructure')
    for dir_name in iac_config['dir_structure']:
        os.makedirs(os.path.join(infra_dir, dir_name), exist_ok=True)

    # Handle separate states for frontend and backend
    if iac_choice.get('generate_separate_states') == 'y':
        if '{{ cookiecutter.architecture_type }}' == 'separate':
            # Frontend infrastructure
            frontend_dir = os.path.join(infra_dir, 'frontend')
            os.makedirs(frontend_dir, exist_ok=True)
            frontend_platform = deployment_config['separate']['frontend']
            create_iac_files(frontend_dir, frontend_platform, iac_config)

            # Backend infrastructure
            backend_dir = os.path.join(infra_dir, 'backend')
            os.makedirs(backend_dir, exist_ok=True)
            backend_platform = deployment_config['separate']['backend']
            create_iac_files(backend_dir, backend_platform, iac_config)
        else:
            # Monolithic infrastructure
            monolithic_dir = os.path.join(infra_dir, 'monolithic')
            os.makedirs(monolithic_dir, exist_ok=True)
            platform = deployment_config['monolithic']
            create_iac_files(monolithic_dir, platform, iac_config)

def create_iac_files(directory, platform, iac_config):
    """Create infrastructure as code files based on platform choice"""
    platform_name = platform.get('name', platform).lower()
    
    templates = {
        'aws': {
            'modules': ['vpc', 'ecs', 'rds', 'elasticache'],
            'resources': ['container', 'database', 'cache', 'cdn']
        },
        'gcp': {
            'modules': ['vpc', 'gke', 'cloudsql', 'memorystore'],
            'resources': ['container', 'database', 'cache', 'cdn']
        },
        'azure': {
            'modules': ['vnet', 'aks', 'database', 'redis'],
            'resources': ['container', 'database', 'cache', 'cdn']
        },
        'digitalocean': {
            'modules': ['vpc', 'kubernetes', 'database', 'spaces'],
            'resources': ['container', 'database', 'storage']
        },
        'hetzner': {
            'modules': ['network', 'kubernetes', 'volume'],
            'resources': ['server', 'loadbalancer', 'firewall']
        },
        'vercel': {
            'modules': ['frontend'],
            'resources': ['deployment', 'domain']
        },
        'netlify': {
            'modules': ['frontend'],
            'resources': ['deployment', 'domain']
        },
        'cloudflare': {
            'modules': ['pages'],
            'resources': ['deployment', 'dns']
        }
    }

    platform_template = templates.get(platform_name, {})
    
    # Create modules
    for module in platform_template.get('modules', []):
        module_dir = os.path.join(directory, 'modules', module)
        os.makedirs(module_dir, exist_ok=True)
        with open(os.path.join(module_dir, f'main.{iac_config["extension"]}'), 'w') as f:
            f.write(f'# {module} module configuration\n')

    # Create main configuration
    with open(os.path.join(directory, f'main.{iac_config["extension"]}'), 'w') as f:
        f.write(f'# Main infrastructure configuration for {platform_name}\n')

    # Create variables
    with open(os.path.join(directory, f'variables.{iac_config["extension"]}'), 'w') as f:
        f.write('# Infrastructure variables\n')

    # Create outputs
    with open(os.path.join(directory, f'outputs.{iac_config["extension"]}'), 'w') as f:
        f.write('# Infrastructure outputs\n')

def run_command(command, cwd=None):
    """Run a shell command"""
    try:
        subprocess.run(command, check=True, shell=True, cwd=cwd)
        return True
    except subprocess.CalledProcessError:
        return False

def setup_git_repository(repo_setup):
    """Set up git repository based on configuration"""
    is_monorepo = repo_setup['name'] == 'Monorepo with submodules'
    default_branch = repo_setup.get('default_branch', 'main')
    org_name = '{{ cookiecutter.git_organization }}'

    # Initialize main repository
    run_command('git init')
    run_command(f'git checkout -b {default_branch}')

    if is_monorepo and repo_setup.get('create_submodules') == 'y':
        # Create and set up frontend repository
        frontend_repo = repo_setup['frontend_repo']
        frontend_path = os.path.join(os.getcwd(), 'frontend')
        if os.path.exists(frontend_path):
            run_command('git init', frontend_path)
            run_command(f'git checkout -b {default_branch}', frontend_path)
            run_command('git add .', frontend_path)
            run_command('git commit -m "Initial frontend commit"', frontend_path)
            # Set up remote (commented out as it requires repository creation)
            # run_command(f'git remote add origin git@github.com:{org_name}/{frontend_repo}.git', frontend_path)
            
            # Add frontend as submodule to main repository
            run_command(f'git submodule add ./frontend')

        # Create and set up backend repository
        backend_repo = repo_setup['backend_repo']
        backend_path = os.path.join(os.getcwd(), 'backend')
        if os.path.exists(backend_path):
            run_command('git init', backend_path)
            run_command(f'git checkout -b {default_branch}', backend_path)
            run_command('git add .', backend_path)
            run_command('git commit -m "Initial backend commit"', backend_path)
            # Set up remote (commented out as it requires repository creation)
            # run_command(f'git remote add origin git@github.com:{org_name}/{backend_repo}.git', backend_path)
            
            # Add backend as submodule to main repository
            run_command(f'git submodule add ./backend')

        # Create .gitmodules if it doesn't exist
        gitmodules_path = os.path.join(os.getcwd(), '.gitmodules')
        if not os.path.exists(gitmodules_path):
            with open(gitmodules_path, 'w') as f:
                f.write(f'''[submodule "frontend"]
    path = frontend
    url = git@github.com:{org_name}/{frontend_repo}.git
[submodule "backend"]
    path = backend
    url = git@github.com:{org_name}/{backend_repo}.git
''')

        # Create development workflow for monorepo
        workflow_dir = os.path.join(os.getcwd(), '.github', 'workflows')
        os.makedirs(workflow_dir, exist_ok=True)
        
        with open(os.path.join(workflow_dir, 'submodule-update.yml'), 'w') as f:
            f.write('''name: Update Submodules

on:
  repository_dispatch:
    types: [update-submodules]
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: recursive
          token: ${{ secrets.SUBMODULE_TOKEN }}
      
      - name: Update submodules
        run: |
          git submodule update --remote --recursive
          git config --global user.name "GitHub Actions"
          git config --global user.email "actions@github.com"
          git add .
          git diff --quiet && git diff --staged --quiet || git commit -m "Update submodules"
          git push
''')

    # Initial commit for main repository
    run_command('git add .')
    run_command('git commit -m "Initial commit"')
    # Set up remote (commented out as it requires repository creation)
    # run_command(f'git remote add origin git@github.com:{org_name}/{project_slug}.git')

def create_readme_for_monorepo():
    """Create a README file for the monorepo"""
    with open('README.md', 'w') as f:
        f.write(f'''# {project_name}

{project_description}

## Repository Structure

This is a monorepo using Git submodules for separate frontend and backend development.

### Submodules

- `frontend/`: Frontend application repository
- `backend/`: Backend application repository

## Development Setup

1. Clone the repository with submodules:
   ```bash
   git clone --recursive git@github.com:{org_name}/{project_slug}.git
   ```

2. Initialize and update submodules:
   ```bash
   git submodule init
   git submodule update
   ```

3. Follow the setup instructions in each submodule's README for specific development guidelines.

## Working with Submodules

### Updating Submodules

To update all submodules to their latest versions:
```bash
git submodule update --remote --merge
```

### Making Changes

1. Navigate to the submodule directory:
   ```bash
   cd frontend  # or cd backend
   ```

2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature
   ```

3. Make your changes, commit, and push to the submodule repository
4. Create a pull request in the submodule repository
5. After merging, update the parent repository to point to the new commit

## Continuous Integration

The repository includes GitHub Actions workflows for:
- Automated submodule updates
- CI/CD pipelines for both frontend and backend
- Infrastructure deployment

## License

{license}
''')

def setup_docker_configuration(tech_choice, architecture_type):
    """Set up Docker configuration based on tech stack choice"""
    if architecture_type == 'separate':
        frontend_tech = tech_choice['separate']['frontend']
        backend_tech = tech_choice['separate']['backend']
        
        # Handle Django separately as it uses cookiecutter-django
        if backend_tech == 'django':
            setup_django_project('backend')
        else:
            # Copy appropriate Dockerfile for backend
            backend_docker_dir = os.path.join('backend', 'docker')
            if os.path.exists(backend_docker_dir):
                source_dockerfile = os.path.join(backend_docker_dir, f'{backend_tech}.Dockerfile')
                if os.path.exists(source_dockerfile):
                    shutil.copy2(source_dockerfile, os.path.join('backend', 'Dockerfile'))
                
                # Clean up docker templates
                shutil.rmtree(backend_docker_dir)
        
        # Handle frontend Dockerfile
        frontend_docker_dir = os.path.join('frontend', 'docker')
        if os.path.exists(frontend_docker_dir):
            source_dockerfile = os.path.join(frontend_docker_dir, f'{frontend_tech}.Dockerfile')
            if os.path.exists(source_dockerfile):
                shutil.copy2(source_dockerfile, os.path.join('frontend', 'Dockerfile'))
            
            # Clean up docker templates
            shutil.rmtree(frontend_docker_dir)

    # Create docker-compose.yml
    create_docker_compose(tech_choice, architecture_type)

def create_docker_compose(tech_choice, architecture_type):
    """Create docker-compose.yml based on tech stack"""
    compose_content = '''version: '3.8'

services:'''
    
    if architecture_type == 'separate':
        # Frontend service
        compose_content += '''
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:80"  # or appropriate port
    environment:
      - NODE_ENV=production'''

        # Backend service
        compose_content += '''
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"  # or appropriate port
    environment:
      - NODE_ENV=production'''

        # Add database service if needed
        if '{{ cookiecutter.database }}' == 'postgres':
            compose_content += '''
  db:
    image: postgres:latest
    environment:
      - POSTGRES_DB=app
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"'''

    # Add volumes if needed
    if '{{ cookiecutter.database }}' == 'postgres':
        compose_content += '''

volumes:
  postgres_data:'''

    with open('docker-compose.yml', 'w') as f:
        f.write(compose_content)

# Get configuration
architecture_type = '{{ cookiecutter.architecture_type }}'
tech_choice = '{{ cookiecutter.tech_choice }}'
auth_choice = '{{ cookiecutter.authentication }}'
deployment_config = '{{ cookiecutter.deployment }}'
iac_choice = '{{ cookiecutter.infrastructure_as_code }}'
repo_setup = '{{ cookiecutter.repository_setup }}'
project_name = '{{ cookiecutter.project_name }}'
project_description = '{{ cookiecutter.project_description }}'
project_slug = '{{ cookiecutter.project_slug }}'
org_name = '{{ cookiecutter.git_organization }}'
license = '{{ cookiecutter.license }}'

# Handle architecture-specific files
if architecture_type == 'monolithic':
    # Remove separate frontend/backend directories
    remove_dir_if_exists('frontend')
    remove_dir_if_exists('backend')
    
    # Handle Django Cookiecutter for monolithic
    if tech_choice['monolithic'].get('django', {}).get('use_cookiecutter_django') == 'y':
        setup_django_cookiecutter(
            'app',
            tech_choice['monolithic']['django']['django_options']
        )
else:
    # Remove monolithic app directory
    remove_dir_if_exists('app')
    
    # Handle Django Cookiecutter for separate backend
    if tech_choice['separate']['backend'].get('django', {}).get('use_cookiecutter_django') == 'y':
        setup_django_cookiecutter(
            'backend',
            tech_choice['separate']['backend']['django']['django_options']
        )

# Set up authentication
setup_auth_provider(auth_choice, '.')

# Handle framework-specific files
if architecture_type == 'monolithic':
    framework = tech_choice['monolithic']
    # Remove unused framework files
    frameworks = ['nextjs', 'nuxtjs', 'quasar', 'django', 'laravel', 'flutter']
    for f in frameworks:
        if f != framework:
            remove_dir_if_exists(f'app/{f}')
else:
    frontend = tech_choice['separate']['frontend']
    backend = tech_choice['separate']['backend']
    
    # Remove unused frontend framework files
    frontends = ['vanilla', 'deno', 'hono', 'react', 'react_native', 'vue', 'quasar', 'flutter']
    for f in frontends:
        if f != frontend:
            remove_dir_if_exists(f'frontend/{f}')
    
    # Remove unused backend framework files
    backends = ['django', 'laravel', 'nuxtjs', 'nextjs', 'quasar_ssr']
    for b in backends:
        if b != backend:
            remove_dir_if_exists(f'backend/{b}')

# Handle HonoJS addons
if frontend == 'hono':
    hono_addons = '{{ cookiecutter.hono_addons }}'
    if 'drizzle' not in hono_addons:
        remove_dir_if_exists('frontend/hono/drizzle')
    if 'prisma' not in hono_addons:
        remove_dir_if_exists('frontend/hono/prisma')
    if 'jwt' not in hono_addons:
        remove_file_if_exists('frontend/hono/auth.ts')
    if 'swagger' not in hono_addons:
        remove_file_if_exists('frontend/hono/swagger.ts')
    if 'zod' not in hono_addons:
        remove_file_if_exists('frontend/hono/validation.ts')

# Handle Quasar addons
if frontend == 'quasar' or tech_choice['monolithic'] == 'quasar':
    quasar_addons = '{{ cookiecutter.quasar_addons }}'
    if 'capacitor' not in quasar_addons:
        remove_dir_if_exists('src-capacitor')
    if 'electron' not in quasar_addons:
        remove_dir_if_exists('src-electron')
    if 'pwa' not in quasar_addons:
        remove_dir_if_exists('src-pwa')
    if 'bex' not in quasar_addons:
        remove_dir_if_exists('src-bex')

# Remove documentation if not needed
if '{{ cookiecutter.include_business_plan }}' != 'y':
    remove_file_if_exists('docs/BUSINESS_PLAN.md')

if '{{ cookiecutter.include_pitch_deck }}' != 'y':
    remove_file_if_exists('docs/PITCH_DECK.md')

if '{{ cookiecutter.include_testing }}' != 'y':
    remove_file_if_exists('docs/TESTING_STRATEGY.md')

# Remove Docker files if not needed
if '{{ cookiecutter.use_docker }}' != 'y':
    remove_file_if_exists('Dockerfile')
    remove_file_if_exists('docker-compose.yml')

# Remove CI files if not needed
if '{{ cookiecutter.include_ci }}' != 'y':
    remove_dir_if_exists('.github')

# Set up infrastructure as code
setup_infrastructure_code(iac_choice, deployment_config)

# Set up git repository
setup_git_repository(repo_setup)

# Create README for monorepo if applicable
if repo_setup['name'] == 'Monorepo with submodules':
    create_readme_for_monorepo()

# Set up Docker configuration
if '{{ cookiecutter.use_docker }}' == 'y':
    setup_docker_configuration(tech_choice, architecture_type)

print('Project successfully created!')
