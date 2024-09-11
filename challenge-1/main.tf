provider "aws" {
  region = var.region
}

locals{
    private_key_path = "./key-pair-2.pem"
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

#Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

#Create Subnet-1
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch  = true

  tags = {
    Name = "subnet-1"
  }
}

#Create Subnet-2 
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-2"
  }
}
# Create a Route Table for the Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

# Associate the Route Table with the Public Subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for the EC2 instances
resource "aws_security_group" "web_sg" {
  name        = var.sg_name
  description = "Allow HTTP and HTTPS"
  vpc_id      = aws_vpc.vpc.id

  # Allow HTTP (80) access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = var.tcp
    cidr_blocks = [var.cidr_block]
  }
  
  # Allow SSH (22) access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = var.tcp
    cidr_blocks = [var.cidr_block]
  }

  # Allow HTTPS (443) access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = var.tcp
    cidr_blocks = [var.cidr_block]
  }

  # Outbound (allow all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }
}

#Launching an EC2 instance
resource "aws_instance" "apache_server"{
    ami = var.ami
    instance_type = var.instance_type
    subnet_id     = aws_subnet.subnet-1.id
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    key_name = "key-pair-2" # This key is already present in AWS

    tags = {
      Name = "apache_server"
    }
}

# Launch template for EC2 with User Data to bootstrap the web server
resource "aws_launch_template" "web_launch_template" {
  name_prefix   = var.lt_name_prefix
  image_id      = var.ami 
  instance_type = var.instance_type

  # Associate the Security Group
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  provisioner "remote-exec"{
    inline = ["echo 'Connected via SSH'"]
    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("./key-pair-2.pem")
        host = aws_instance.apache_server.public_ip
  }
  }

  provisioner "local-exec"{
    command = "ansible-playbook -i ${aws_instance.apache_server.public_ip}, --private-key ${local.private_key_path} apache-setup.yaml"
  }

  provisioner "local-exec"{
    command = "ansible-playbook -i ${aws_instance.apache_server.public_ip}, --private-key ${local.private_key_path} ./validator.sh"
  }

  depends_on = [aws_instance.apache_server]
  }

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
  health_check_type    = "ELB"
  health_check_grace_period = 300

  launch_template{
    id = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }

  # Attach Load Balancer
  target_group_arns = [aws_lb_target_group.web_tg.arn]
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "web_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = var.lb_type
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
}

# Target group for the ALB
resource "aws_lb_target_group" "web_tg" {
  name     = var.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

# ALB HTTP Listener for redirection
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB HTTPS Listener
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:730335214337:certificate/"  # Update this with your ACM SSL certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

/* The above cofiguration will spin up an EC2 instance with VPC, Internet Gateway, subnets, ALB,, target group, 2 listners
HTTP and HTTPs. All the HTTP traffic will be forwarded to the HTTPS listner. For the HTTPs listerner we need to have additional 
setup on Route53 likecreate a Domain name, Hosted Zone, Records(attach the ALB's DNS to the record), Request for SSL on ACM 
and attach the SSL policy to the prefered Domain name. We can also setup AWS Sheild for security. All this will incure cost.*/
