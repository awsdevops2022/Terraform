
provider "aws" {
    region = "ap-south-1"
}

module "alb" {
    source = "./alb"
    vpc_cidr_block = "172.0.0.0/16"
    vpc_name = "test-vpc"
    public_1a_subnet_cidr_block = "172.0.0.0/24"
    subnet_1a = "test-public-1a"
    public_1b_subnet_cidr_block = "172.0.1.0/24"
    subnet_1b = "test-public-1b"
    igw = "test-igw"
}
