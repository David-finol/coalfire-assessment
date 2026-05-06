# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

# Availability Zones data source
data "aws_availability_zones" "available" {
  state = "available"
}

# Application Subnets (Public - in 2 AZs)
resource "aws_subnet" "application" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.application_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-application-subnet-${count.index + 1}"
      Tier = "Application"
    }
  )
}

# Management Subnet (Public - in 1 AZ)
resource "aws_subnet" "management" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.management_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-management-subnet"
      Tier = "Management"
    }
  )
}

# Backend Subnets (Private - in 2 AZs)
resource "aws_subnet" "backend" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.backend_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-backend-subnet-${count.index + 1}"
      Tier = "Backend"
    }
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways in Management subnet
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = count.index == 0 ? aws_subnet.management.id : aws_subnet.application[1].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Route Table for Management Subnet (has IGW route)
resource "aws_route_table" "management" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-management-rt"
    }
  )
}

# Route Table Association for Management Subnet
resource "aws_route_table_association" "management" {
  subnet_id      = aws_subnet.management.id
  route_table_id = aws_route_table.management.id
}

# Route Tables for Application Subnets (NAT routes)
resource "aws_route_table" "application" {
  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-application-rt-${count.index + 1}"
    }
  )
}

# Route Table Associations for Application Subnets
resource "aws_route_table_association" "application" {
  count          = 2
  subnet_id      = aws_subnet.application[count.index].id
  route_table_id = aws_route_table.application[count.index].id
}

# Route Tables for Backend Subnets (NAT routes)
resource "aws_route_table" "backend" {
  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-backend-rt-${count.index + 1}"
    }
  )
}

# Route Table Associations for Backend Subnets
resource "aws_route_table_association" "backend" {
  count          = 2
  subnet_id      = aws_subnet.backend[count.index].id
  route_table_id = aws_route_table.backend[count.index].id
}
