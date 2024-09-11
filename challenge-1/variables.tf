variable region{
    description = "This is the AWS region"
    type = string
    default = "us-east-1"
}

variable ami{
    description = "AMI for the instance"
    type = string
    default = "ami-0182f373e66f89c85"
}

variable instance_type{
    description = "Type of ec2 instance"
    type = string
    default = "t2.micro"
}

variable sg_name{
    description = "Name of the Security Group"
    type = string
    default = "web_security_group"
}

variable tcp{
    description = "TCP protocol"
    type = string
    default = "tcp"
}

variable cidr_block{
    description = "CIDR block under SG's"
    type = string
    default = "0.0.0.0/0"
}

variable lt_name_prefix{
    description = "Name prefix for the launch template"
    type = string
    default = "web-template"
}

variable alb_name{
    description = "Name of the Application Load Balancer"
    type = string
    default = "web-alb"
}

variable lb_type{
    description = "Type of the Load Balancer"
    type = string
    default = "application"
}

variable tg_name{
    description = "Name of the target group"
    type = string
    default = "web-target-group"
}