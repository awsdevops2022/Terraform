
resource "aws_vpc" "test_vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    tags = {
        Name = var.vpc_name
    }
}

resource "aws_subnet" "public_1a" {
    cidr_block = var.public_1a_subnet_cidr_block
    map_public_ip_on_launch = true
    availability_zone = "ap-south-1a"
    vpc_id = aws_vpc.test_vpc.id
    tags = {
        Name = var.subnet_1a
    }
}

resource "aws_subnet" "public_1b" {
    cidr_block = var.public_1b_subnet_cidr_block
    map_public_ip_on_launch = true
    availability_zone = "ap-south-1b"
    vpc_id = aws_vpc.test_vpc.id
    tags = {
        Name = var.subnet_1b
    }
}

resource "aws_internet_gateway" "igw_test" {
    vpc_id = aws_vpc.test_vpc.id
    tags = {
        Name = var.igw
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.test_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_test.id
    }
    tags = {
        Name = "test-public-rt"
    }
}

resource "aws_route_table_association" "public_rt_1a" {
    subnet_id = aws_subnet.public_1a.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_1b" {
    subnet_id = aws_subnet.public_1b.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "instance_rules" {
    name = "test-sg"
    vpc_id = aws_vpc.test_vpc.id 
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb_rules.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [aws_security_group.alb_rules.id]
    }
}

resource "aws_security_group" "alb_rules" {
    name = "test-alb"
    vpc_id = aws_vpc.test_vpc.id 
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
} 

resource "aws_lb_target_group" "testTarget"{
    name = "test-target"
    protocol = "HTTP"
    port = 80
    vpc_id = aws_vpc.test_vpc.id
    health_check {
        enabled = true
        path = "/"
        matcher = "200"
        healthy_threshold = 4
        interval = 6
        unhealthy_threshold = 4
        port = 80
        protocol = "HTTP"
    }
    target_type = "instance"
}

resource "aws_lb_listener" "test_listener" {
    load_balancer_arn = aws_lb.test_alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.testTarget.arn
    }
}

resource "aws_lb" "test_alb" {
    name = "test-alb"
    internal = false 
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_rules.id]
    subnets = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
    tags = {
        Name = "test-alb"
    }
}   
