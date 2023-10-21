terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = "us-east-2"
}

#VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" #Error: expected "cidr_block" to contain a network Value with between 16 and 28 significant bits, got: 8
}

resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.ig]
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "nat"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "$private-route-table"
  }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Subnet privada
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24" # "10.0.2.0/22" is not a valid IPv4 CIDR block 
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false #No le da IP publica
}


resource "aws_ec2_instance_connect_endpoint" "Direct_to_private" {
  subnet_id          = aws_subnet.private_subnet.id
  preserve_client_ip = false
}


# Virtual machine privada
resource "aws_instance" "private_vm" {
  ami           = "ami-024e6efaf93d85776"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.security_group.id]
  key_name = "testKey"
  tags = {

    Name = "Private VM"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt install apache2 -y
              echo "<h1>Hello world!</h1><h2>Servidor privado!</h2>" | sudo tee /var/www/html/index.html
              sudo service apache2 restart
                            
              EOF
}


# Subnet publica
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-2a" # 
  map_public_ip_on_launch = true         #
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "vpc_igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


# Virtual machine publica 
resource "aws_instance" "public_vm" {
  ami             = "ami-024e6efaf93d85776"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.security_group.id]
  key_name = "testKey"
  tags = {

    Name = "Public VM"
  }
  user_data = file("publicUserData.sh")
}


output "private_ip" {
  value = aws_instance.private_vm.private_ip
}

output "public_ip" {
  value = aws_instance.public_vm.public_ip
}

output "vpn_ip" {
  value = aws_instance.OpenVPN.public_ip
}

# Security group
resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.my_vpc.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1 # ICMP
    to_port     = -1 # ICMP
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# Virtual machine VPN 
resource "aws_instance" "OpenVPN" {
  ami             = "ami-0b26ff452fd594f13"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.vpn_security_group.id]
  key_name = "testKey"
  tags = {
    Name = "VPN"
  }
}


# Security group para el VPN (usa puertos que no se requerian en el proyecto)
resource "aws_security_group" "vpn_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1 # ICMP
    to_port     = -1 # ICMP
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}