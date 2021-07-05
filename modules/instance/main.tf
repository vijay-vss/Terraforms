resource "aws_default_security_group" "myapp-default-sg" {
    vpc_id = var.vpc_id

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
    subnet_id = var.subnet_id
    availability_zone = "ap-south-1a"
    associate_public_ip_address = true
    key_name = "myapp-key"

    tags = {
        Name = "${var.env-prefix}-server"
    }
}
