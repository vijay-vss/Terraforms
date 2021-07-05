resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "${var.env-prefix}-vpc"
    }
}
module "myapp-subnet1" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.myapp-vpc.id
    subnet_one_cidr = var.subnet_one_cidr
    env-prefix = var.env-prefix
}

module "myapp-instance" {
    source = "./modules/instance"
    vpc_id = aws_vpc.myapp-vpc.id
    env-prefix = var.env-prefix
    subnet_id = module.myapp-subnet1.subnet.id
    instance-type = var.instance-type
    public-key-file = var.public-key-file
}
