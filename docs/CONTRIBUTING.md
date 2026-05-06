# Contributing Guidelines

This project welcomes contributions! Here's how to contribute:

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/coalfire-assessment.git`
3. Create a feature branch: `git checkout -b feature/your-feature`

## Development Setup

```bash
# Install dependencies
brew install terraform awscli  # macOS
sudo apt-get install terraform awscli  # Linux

# Initialize development environment
bash scripts/setup.sh

# Create your own terraform.tfvars
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit with your settings
```

## Code Style

### Terraform

- Run `terraform fmt -recursive` before committing
- Use consistent naming: `{resource_type}_{purpose}_{detail}`
- Add comments for complex logic
- Group related resources together
- Use variables for all configurable values

### Documentation

- Use clear, concise language
- Include code examples
- Add table of contents for long documents
- Keep line length reasonable (80-100 chars)
- Update README when adding features

## Making Changes

### Before You Start

1. Check existing issues and PRs
2. Open an issue to discuss large changes
3. Follow the project structure

### While Developing

1. Create descriptive commit messages
2. Test your changes: `terraform validate && terraform fmt -check`
3. Update documentation
4. Add comments for complex code

### Terraform Module Changes

If modifying modules:

```bash
# Validate each module
cd terraform/modules/networking
terraform validate

# Format code
terraform fmt -recursive

# Test in dev environment
cd terraform/environments/dev
terraform plan
terraform apply
```

## Testing

### Validate Syntax

```bash
# All modules
terraform validate
terraform fmt -check -recursive

# Specific module
cd terraform/modules/networking
terraform validate
```

### Plan Changes

```bash
cd terraform/environments/dev
terraform plan -out=tfplan
# Review the output for expected changes
```

### Apply in Dev

```bash
# Apply to dev first
terraform apply

# Verify resources are created correctly
terraform output
```

## Submitting Changes

### Commit Messages

Use clear commit messages:
```
fix: incorrect security group rule for ALB

Resolves #123

The ALB security group was missing HTTP from
the internet. Added inbound rule for port 80
from 0.0.0.0/0.
```

### Creating a Pull Request

1. Push to your fork
2. Create a pull request with:
   - Clear title and description
   - Reference to related issues
   - Before/after if UI changes
   - Testing instructions

3. Wait for review and CI checks
4. Address feedback
5. Rebase if needed

## Documentation

### Adding Documentation

When adding features, update:
- README.md (overview)
- Relevant doc in docs/
- Code comments
- CHANGELOG (if maintained)

### Documentation Format

```markdown
# Section Title

Brief description of what this section covers.

## Subsection

More details here with examples:

\`\`\`hcl
# Example code
\`\`\`
```

## Issue Reporting

When reporting issues:

1. **Use a clear title**: "Cannot SSH to management instance"
2. **Provide environment info**:
   ```
   - OS: macOS 12.1
   - Terraform: 1.5.0
   - AWS CLI: 2.13.0
   ```
3. **Steps to reproduce**
4. **Expected behavior**
5. **Actual behavior**
6. **Error messages** (full output if possible)
7. **Potential solutions**

## Pull Request Review

PRs should:
- [ ] Follow code style
- [ ] Include updates to docs
- [ ] Pass all validation
- [ ] Have clear commit history
- [ ] Be focused on one feature/fix
- [ ] Include comments for complex logic

## Code of Conduct

- Be respectful and inclusive
- Welcome differing opinions
- Provide constructive feedback
- No harassment or discrimination

## Questions?

- Open a GitHub issue
- Check existing documentation
- Look at similar implementations
- Ask in PR comments

---

Thank you for contributing! Your help makes this project better. 🎉
