# Infrastructure as Code (IaC)

This directory contains OpenTofu/Terraform configurations for deploying the application infrastructure across different cloud providers.

## Directory Structure

```
infrastructure/
├── aws/                  # AWS Infrastructure
│   ├── main.tf          # Main AWS configuration
│   ├── variables.tf     # Input variables
│   └── modules/         # AWS resource modules
├── gcp/                  # Google Cloud Infrastructure
│   ├── main.tf          # Main GCP configuration
│   ├── variables.tf     # Input variables
│   └── modules/         # GCP resource modules
└── azure/               # Azure Infrastructure
    ├── main.tf          # Main Azure configuration
    ├── variables.tf     # Input variables
    └── modules/         # Azure resource modules
```

## Common Infrastructure Components

Each cloud provider configuration includes:

- Virtual Network/VPC
- Kubernetes Cluster (EKS/GKE/AKS)
- Database (RDS/Cloud SQL/Azure Database)
- Redis Cache
- Load Balancer
- Object Storage
- IAM/Security configurations

## Usage

1. Choose your cloud provider directory
2. Initialize Terraform:
   ```bash
   cd <cloud-provider>
   terraform init
   ```

3. Create a `terraform.tfvars` file with your variables:
   ```hcl
   project_name = "my-app"
   environment = "production"
   # ... other variables
   ```

4. Plan your infrastructure:
   ```bash
   terraform plan -out=tfplan
   ```

5. Apply the configuration:
   ```bash
   terraform apply tfplan
   ```

## Cloud-Specific Notes

### AWS
- Uses ECS for container orchestration
- RDS for managed database
- ElastiCache for Redis
- Application Load Balancer
- S3 for object storage

### Google Cloud
- Uses GKE for container orchestration
- Cloud SQL for managed database
- Memorystore for Redis
- Cloud Load Balancing
- Cloud Storage for objects

### Azure
- Uses AKS for container orchestration
- Azure Database for PostgreSQL
- Azure Cache for Redis
- Application Gateway
- Azure Storage Account

## Security Considerations

- All databases are deployed in private subnets
- Network security groups/firewall rules are configured
- Encryption at rest is enabled for all storage
- TLS/SSL certificates are managed through cloud providers
- IAM roles follow least privilege principle

## Cost Optimization

- Use auto-scaling where possible
- Implement proper tagging for cost allocation
- Consider reserved instances for production workloads
- Monitor and clean up unused resources

## Maintenance

- Regularly update provider versions
- Monitor for security advisories
- Implement proper state management
- Use workspaces for multiple environments

## Contributing

When adding new infrastructure components:

1. Create a new module in the appropriate cloud provider's modules directory
2. Update the main configuration file
3. Document any new variables or outputs
4. Test in a non-production environment first

## Troubleshooting

Common issues and solutions:

1. State Lock Issues
   ```bash
   terraform force-unlock <lock-id>
   ```

2. Provider Authentication
   - AWS: Configure AWS CLI or use environment variables
   - GCP: Use service account key or workload identity
   - Azure: Use Azure CLI or service principal

3. Resource Cleanup
   ```bash
   terraform destroy -target=module.resource_name
   ```
