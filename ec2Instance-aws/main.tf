
provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "dev" {
    cidr_block = "192.0.0.0/16"
    enable_dns_hostnames = true
    tags = {
        Name = "dev-vpc"
    }
}

resource "aws_subnet" "public" {
    cidr_block = "192.0.1.0/24"
    vpc_id = aws_vpc.dev.id
    map_public_ip_on_launch = true
    availability_zone = "ap-south-1a"
    tags = {
        Name = "dev-public-subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.dev.id
    tags = {
        Name = "dev-igw"
    }
}

resource "aws_route_table" "pubilc_rt" {
    vpc_id = aws_vpc.dev.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    } 
    tags = {
        Name = "dev-public-rt"
    }
}

resource "aws_route_table_association" "dev-rt" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.pubilc_rt.id
}

resource "aws_security_group" "rules" {
    name = "dev-sg"
    vpc_id = aws_vpc.dev.id 
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
    }

    tags = {
        Name = "dev-sg"
    }
}

resource "aws_key_pair" "keypair" {
    key_name = "devKey"
    public_key = file("devKey.pub")
}

resource "aws_instance" "dev_instance" {
    key_name = aws_key_pair.keypair.key_name
    associate_public_ip_address = true
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    ami = "ami-0d2986f2e8c0f7d01"
    vpc_security_group_ids = [aws_security_group.rules.id]
    tags = {
        Name = "dev-instance"
    }
}
