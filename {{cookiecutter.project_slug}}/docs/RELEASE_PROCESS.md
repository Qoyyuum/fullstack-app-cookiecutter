# Release Process

This document outlines the process for creating new releases and publishing Docker images to the GitHub Container Registry (GHCR).

## Version Tagging

We use semantic versioning (SemVer) for our releases. Version numbers should follow the pattern: `vMAJOR.MINOR.PATCH`

- **MAJOR**: Incompatible API changes
- **MINOR**: Added functionality in a backwards compatible manner
- **PATCH**: Backwards compatible bug fixes

## Creating a New Release

1. Ensure your local repository is up to date:
   ```bash
   git fetch origin
   git checkout main
   git pull origin main
   ```

2. Create and push a new version tag:
   ```bash
   # For a new patch release
   git tag v1.0.1
   
   # For a new minor release
   git tag v1.1.0
   
   # For a new major release
   git tag v2.0.0
   
   # Push the tag
   git push origin --tags
   ```

## Automated Release Process

When you push a version tag, the following automated processes will occur:

1. The `publish.yml` workflow will trigger automatically
2. Docker images will be built and published to GHCR
3. A GitHub Release will be created with the changelog

## Docker Images

{% if cookiecutter.architecture_type == "separate" %}
The workflow publishes two Docker images:
- `ghcr.io/{{ cookiecutter.git_organization }}/{{ cookiecutter.project_slug }}-frontend:VERSION`
- `ghcr.io/{{ cookiecutter.git_organization }}/{{ cookiecutter.project_slug }}-backend:VERSION`
{% else %}
The workflow publishes one Docker image:
- `ghcr.io/{{ cookiecutter.git_organization }}/{{ cookiecutter.project_slug }}:VERSION`
{% endif %}

Each image is tagged with:
- Full version (e.g., `v1.0.1`)
- Minor version (e.g., `v1.0`)
- Commit SHA

## Pulling the Images

To pull the latest version:
```bash
{% if cookiecutter.architecture_type == "separate" %}
# Pull frontend image
docker pull ghcr.io/{{ cookiecutter.git_organization }}/{{ cookiecutter.project_slug }}-frontend:latest

# Pull backend image
docker pull ghcr.io/{{ cookiecutter.git_organization }}/{{ cookiecutter.project_slug }}-backend:latest
{% else %}
# Pull application image
docker pull ghcr.io/{{ cookiecutter.git_organization }}/{{ cookiecutter.project_slug }}:latest
{% endif %}
```

To pull a specific version:
```bash
{% if cookiecutter.architecture_type == "separate" %}
# Pull frontend image
docker pull ghcr.io/{{ cookiecutter.git_organization }}/{{ cookiecutter.project_slug }}-frontend:v1.0.1

# Pull backend image
docker pull ghcr.io/{{ cookiecutter.git_organization }}/{{ cookiecutter.project_slug }}-backend:v1.0.1
{% else %}
# Pull application image
docker pull ghcr.io/{{ cookiecutter.git_organization }}/{{ cookiecutter.project_slug }}:v1.0.1
{% endif %}
```

## Release Checklist

Before creating a new release:

1. [ ] All tests are passing in CI
2. [ ] Documentation is up to date
3. [ ] CHANGELOG.md is updated
4. [ ] All security scans pass
5. [ ] Version numbers are updated in relevant files
6. [ ] API documentation is updated (if applicable)

## Troubleshooting

If the workflow fails:

1. Check the workflow logs in GitHub Actions
2. Ensure GitHub Packages permissions are correctly set
3. Verify the repository secrets are properly configured
4. Check if the Docker build context is correct
5. Verify the version tag follows the correct format

## Rolling Back a Release

If you need to roll back a release:

1. Delete the problematic tag:
   ```bash
   # Locally
   git tag -d v1.0.1
   
   # On remote
   git push origin :refs/tags/v1.0.1
   ```

2. Create a new patch release with the fixed code

## Security Considerations

- Never include sensitive information in release notes
- Always scan Docker images for vulnerabilities before release
- Keep dependencies up to date
- Follow the principle of least privilege for container configurations
