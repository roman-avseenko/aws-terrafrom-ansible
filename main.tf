terraform {
  required_version = "~> 1.0.0"
  required_providers {
    aws = ">= 3.46.0"
    tls = "~> 3.1.0"
  }
}

provider "aws" {
  region = "eu-central-1"
}

###################################################
#---------------Create custom VPC-----------------#
###################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "lab2-vpc"
  cidr = "100.100.0.0/16"

  azs            = ["eu-central-1a"]
  public_subnets = ["100.100.100.0/24"]
  public_subnet_tags = {
    Name = "lab2-subnet"
  }

  enable_dns_hostnames = true

  tags = var.common_tags
}

###################################################
#-------Create security group for web server------#
###################################################
module "ssh_http_icmp_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "WebServerSG"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = var.common_tags

  depends_on = [module.vpc]
}

###################################################
#------Create security group for data server------#
###################################################
module "ssh_icmp_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "DataServerSG"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = var.common_tags

  depends_on = [module.vpc]
}

###################################################
#-----------Search for CentOS7 recent AMI---------#
#----------------(for web server)-----------------#
###################################################
data "aws_ami" "web_server" {
  owners      = ["125523088429"] # Search for official CentOS AMI
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS 7* x86_64"]
  }
}

###################################################
#-----------Search for CentOS8 recent AMI---------#
#----------------(for data server)-----------------#
###################################################
data "aws_ami" "data_server" {
  owners      = ["125523088429"] # Search for official CentOS AMI
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS 8* x86_64"]
  }
}

###################################################
#--------------SSH key pair generation------------#
###################################################
resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "aws_key_pair" "this" {
  key_name   = "servers-key"
  public_key = tls_private_key.this.public_key_openssh
}

# Generate private key local file
resource "local_file" "this" {
  filename          = "${aws_key_pair.this.key_name}.pem"
  file_permission   = "0400"
  sensitive_content = tls_private_key.this.private_key_pem
}

###################################################
#----------Web server EC2 instance create---------#
###################################################
resource "aws_instance" "web_server" {

  ami                    = data.aws_ami.web_server.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.ssh_http_icmp_sg.security_group_id]
  private_ip             = "100.100.100.10"

  root_block_device {
    volume_size = 15
  }

  # Change hostname inside this machine
  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname vm-01
EOF

  tags = merge(var.common_tags, {
    Name = "Web"
  })

  depends_on = [module.ssh_http_icmp_sg]
}
###################################################
#----------Data server EC2 instance create---------#
###################################################
resource "aws_instance" "data_server" {

  ami                    = data.aws_ami.data_server.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.ssh_icmp_sg.security_group_id]
  private_ip             = "100.100.100.11"

  root_block_device {
    volume_size = 15
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 5
  }

  # Change hostname inside this machine
  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname vm-02
EOF

  tags = merge(var.common_tags, {
    Name = "Data"
  })

  depends_on = [module.ssh_icmp_sg]
}
