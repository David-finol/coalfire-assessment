# Project Overview

## Coalfire SRE Assessment

This is a complete Infrastructure-as-Code solution for the Coalfire SRE technical assessment challenge.

## Challenge Requirements Met

### ✅ Network
- [x] VPC: 10.1.0.0/16
- [x] 3 subnets across 2 AZs (Application, Management, Backend - all /24)
- [x] Management subnet accessible from internet
- [x] Other subnets NOT accessible from internet

### ✅ Compute
- [x] EC2 in ASG running Linux (Amazon Linux 2) in application subnet
- [x] Security group allows SSH from management EC2
- [x] Security group allows web traffic from ALB
- [x] No external traffic to ASG
- [x] Apache web server auto-installed via user data
- [x] 2 minimum, 6 maximum hosts
- [x] t2.micro sized instances
- [x] Management EC2 running Linux in management subnet
- [x] Management SG allows SSH from specific IP only
- [x] Can SSH from management to ASG instances
- [x] t2.micro sized

### ✅ Supporting Infrastructure
- [x] Application Load Balancer routes web traffic to ASG
- [x] Proper health checks
- [x] Cross-AZ distribution

## Project Structure

```
coalfire-assessment/
├── terraform/              # IaC code
├── .github/workflows/      # CI/CD pipelines
├── docs/                   # Documentation
├── scripts/                # Helper scripts
├── Makefile                # Task automation
└── README.md               # Main documentation
```

## Key Features

### Infrastructure
- **Modular Design** - Reusable components
- **Security** - Network segmentation, IAM policies
- **High Availability** - Multi-AZ deployment
- **Auto Scaling** - Dynamic capacity management
- **Load Balancing** - Distributed traffic
- **Bastion Host** - Secure SSH access

### Deployment
- **State Management** - S3 + DynamoDB
- **CI/CD** - GitHub Actions automation
- **Version Control** - Git tracking
- **Documentation** - Comprehensive guides

## Getting Started

1. Read [README.md](../README.md) for overview
2. Follow [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for setup
3. Check [ARCHITECTURE.md](ARCHITECTURE.md) for design details
4. Use [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for common tasks

## Documentation Map

| Document | Purpose |
|----------|---------|
| README.md | Project overview and getting started |
| DEPLOYMENT_GUIDE.md | Step-by-step deployment instructions |
| ARCHITECTURE.md | Network and system design |
| TROUBLESHOOTING.md | Problem solutions |
| QUICK_REFERENCE.md | Fast command reference |
| ENVIRONMENTS.md | Multi-environment setup |
| PRODUCTION_CHECKLIST.md | Pre-production requirements |
| CONTRIBUTING.md | Contribution guidelines |

## Technologies Used

- **Terraform** - Infrastructure as Code
- **AWS** - Cloud platform
  - VPC, Subnets, NAT Gateways
  - EC2, Auto Scaling Groups
  - Application Load Balancer
  - Security Groups, IAM roles
  - S3, DynamoDB
- **GitHub Actions** - CI/CD
- **Bash/PowerShell** - Setup scripts

## Resource Naming Convention

All AWS resources follow the naming pattern: `{environment}-{component}`

**Examples**:
- `dev-vpc` - VPC for dev
- `dev-management-subnet` - Management subnet
- `dev-app-asg` - Application Auto Scaling Group
- `dev-alb` - Application Load Balancer
- `dev-app-instance` - EC2 instance

## Default Regions and AZs

- **Region**: us-east-1 (configurable)
- **Availability Zones**: Automatically selected
  - AZ1: us-east-1a
  - AZ2: us-east-1b

## Estimated Deployment Time

| Phase | Time |
|-------|------|
| Setup (first time) | 5-10 min |
| Terraform init | 1-2 min |
| Infrastructure creation | 8-12 min |
| Total first deployment | 15-25 min |
| Subsequent deployments | 5-10 min |

## Estimated Monthly Costs

| Resource | Estimated Cost |
|----------|----------------|
| EC2 instances (2-6) | $5-15 |
| NAT Gateways (2) | ~$15 |
| Application Load Balancer | ~$16 |
| Data transfer | ~$0-5 |
| S3 & DynamoDB | <$1 |
| **Total** | ~$40-50 |

*Note: Costs vary by region and usage*

## Support and Resources

### Documentation
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS Provider Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Getting Help
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review relevant guide in docs/
3. Open GitHub issue
4. Check AWS/Terraform community forums

## Project Status

| Component | Status |
|-----------|--------|
| Networking | ✅ Complete |
| Security Groups | ✅ Complete |
| Compute | ✅ Complete |
| Load Balancing | ✅ Complete |
| State Backend | ✅ Complete |
| CI/CD Pipeline | ✅ Complete |
| Documentation | ✅ Complete |
| Deployment Scripts | ✅ Complete |

## Future Enhancements

- [ ] Monitoring dashboards (CloudWatch)
- [ ] Automated backups
- [ ] SSL/TLS support (HTTPS)
- [ ] Database tier (RDS)
- [ ] Caching layer (ElastiCache)
- [ ] Multi-region failover
- [ ] Auto-scaling policies
- [ ] Application deployment pipeline
- [ ] Configuration management
- [ ] Disaster recovery testing

## License

MIT License - See LICENSE file

---

**Last Updated**: May 2024
**Version**: 1.0.0
**Assessment Status**: ✅ Complete
