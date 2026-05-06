.PHONY: help init plan apply destroy validate fmt clean state-init

help:
	@echo "Coalfire Assessment - Terraform Management"
	@echo ""
	@echo "Available commands:"
	@echo "  make init           - Initialize Terraform for dev environment"
	@echo "  make validate       - Validate Terraform configuration"
	@echo "  make fmt            - Format Terraform files"
	@echo "  make plan           - Plan Terraform changes for dev"
	@echo "  make apply          - Apply Terraform changes for dev"
	@echo "  make destroy        - Destroy infrastructure in dev"
	@echo "  make state-init     - Initialize state backend in S3/DynamoDB"
	@echo "  make clean          - Clean Terraform cache and files"
	@echo "  make outputs        - Show Terraform outputs"
	@echo ""

state-init:
	@echo "Initializing Terraform State Backend..."
	cd terraform/state-backend && \
	terraform init && \
	terraform apply
	@echo "State backend created. Update backend config in terraform/environments/dev/main.tf"

init:
	@echo "Initializing Terraform for dev environment..."
	cd terraform/environments/dev && terraform init

validate:
	@echo "Validating Terraform configuration..."
	cd terraform/environments/dev && terraform validate
	terraform fmt -check -recursive terraform/ || true

fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive terraform/

plan:
	@echo "Planning Terraform changes for dev environment..."
	cd terraform/environments/dev && terraform plan -out=tfplan

apply:
	@echo "Applying Terraform changes for dev environment..."
	cd terraform/environments/dev && terraform apply tfplan

destroy:
	@echo "WARNING: Destroying infrastructure in dev environment..."
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd terraform/environments/dev && terraform destroy; \
	fi

outputs:
	@echo "Terraform Outputs:"
	cd terraform/environments/dev && terraform output

clean:
	@echo "Cleaning Terraform files..."
	find terraform -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find terraform -name ".terraform.lock.hcl" -delete
	find terraform -name "tfplan" -delete
	find terraform -name "*.tfstate*" -delete
	find terraform -name "crash.log" -delete
	@echo "Clean completed"
