provider "aws" {
    region = "ap-south-1"
}

variable "vpc_cidr" {}
variable "env-prefix" {}
variable "subnet_one_cidr" {}
variable "instance-type" {}
variable "public-key-file" {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "${var.env-prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_one_cidr
    availability_zone = "ap-south-1a"
    tags = {
        Name = "${var.env-prefix}-subnet-one"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name = "${var.env-prefix}-igw"
    }
}

resource "aws_route_table" "myapp-rt" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env-prefix}-rt"
    }
}

resource "aws_route_table_association" "myapp-rt-a" {
    subnet_id = aws_subnet.myapp-subnet1.id
    route_table_id = aws_route_table.myapp-rt.id
}

resource "aws_default_security_group" "myapp-default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
        Name = "${var.env-prefix}-default-sg"
    }
}

data "aws_ami" "myapp-ami" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-2.*-x86_64-gp2"] 
    }
}

resource "aws_key_pair" "ssh-key" {
   key_name = "myapp-key"
   public_key = file(var.public-key-file)
}
resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.myapp-ami.id
    instance_type = var.instance-type
    subnet_id = aws_subnet.myapp-subnet1.id
    availability_zone = "ap-south-1a"
    associate_public_ip_address = true
    key_name = "myapp-key"

    tags = {
        Name = "${var.env-prefix}-server"
    }
}

# this file is main.tf
