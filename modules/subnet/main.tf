resource "aws_subnet" "myapp-subnet1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_one_cidr
    availability_zone = "ap-south-1a"
    tags = {
        Name = "${var.env-prefix}-subnet-one"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.env-prefix}-igw"
    }
}

resource "aws_route_table" "myapp-rt" {
    vpc_id = var.vpc_id
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
