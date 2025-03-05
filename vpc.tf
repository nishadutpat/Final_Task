


resource "aws_vpc" "my_vpc_gdtc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw_gdtc" {
  vpc_id = aws_vpc.my_vpc_gdtc.id

  tags = {
    Name = "MyInternetGatewaygdtc"
  }
}

# Create a Public Subnet
resource "aws_subnet" "public_subnet_gdtc" {
  vpc_id                  = aws_vpc.my_vpc_gdtc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "PublicSubnetgdtc"
  }
}

# Create a Private Subnet
resource "aws_subnet" "private_subnet_gdtc" {
  vpc_id            = aws_vpc.my_vpc_gdtc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "PrivateSubnetgdtc"
  }
}

# Create a Route Table for Public Subnet
resource "aws_route_table" "public_rt_gdtc" {
  vpc_id = aws_vpc.my_vpc_gdtc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw_gdtc.id
  }

  tags = {
    Name = "PublicRouteTablegdtc"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet_gdtc.id
  route_table_id = aws_route_table.public_rt_gdtc.id
}

# Create a Security Group
resource "aws_security_group" "my_sg_gdtc" {
  vpc_id = aws_vpc.my_vpc_gdtc.id

  # Allow SSH (22) from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (80) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroupgdtc"
  }
}
