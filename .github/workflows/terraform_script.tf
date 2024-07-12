terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.57.0"
    }
  }
}
terraform{
    backend "s3"{
        bucket = "devops-assignment-s3-bucket"
        key = "env/dev/terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {  
    region = "us-east-1"
}
    
resource "aws_vpc" "devops_vpc" {    
    cidr_block = "20.0.0.0/16"
    tags = {
        Name = "DEVOPS"
    }
}
    
resource "aws_subnet" "devops_public_subnet" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = "20.0.0.0/16"
    availability_zone = "us-east-1e"
    
    tags = {
        Name = "DEVOPS_subnet"
    }
}

resource "aws_internet_gateway" "devops-igw" {
    vpc_id = aws_vpc.devops_vpc.id    
    tags = {
        Name = "DEVOPS_Internet_Gateway"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.devops_vpc.id  
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devops-igw.id
    }

    tags = {
        Name = "Devops_Public_RouteTable"
    }
}

resource "aws_route_table_association" "public_subnet_routetable_a" {
    subnet_id      = aws_subnet.devops_public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
    name   = "HTTP and SSH"
    vpc_id = aws_vpc.devops_vpc.id  
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    #jenkins port
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    #sonarqube port
    ingress {
        from_port   = 9000
        to_port     = 9000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    #posgress port -> used by sonarqube
    ingress {
        from_port   = 5000
        to_port     = 5000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}




resource "aws_instance" "web_instance" {  
    instance_type = "t2.micro"
    availability_zone = "us-east-1e"

    ami = "ami-04a81a99f5ec58529"
    subnet_id = aws_subnet.devops_public_subnet.id

    vpc_security_group_ids = [aws_security_group.web_sg.id]
    
    associate_public_ip_address = true
    
    #key_name = aws_key_pair.key_pair.key_name  
    #key_name = "devops_keypair2"
    tags = {
        Name = "EC2-instance"}
}

# resource "tls_private_key" "rsa_4096"{
#     algorithm = "RSA"
#     rsa_bits = 4096
# }


#resource "aws_key_pair" "key_pair" {
#  key_name   = "devops_keypair" #var.key_name
#  public_key = file("~/.ssh/devops_keypair.pub")
#}

# resource "local_file" "private_key" {
#      content = tls_private_key.rsa_4096.private_key_pem
#      filename = "devops_keypair" #var.key_name
  
# }
variable "key_name" {
  description = "The name of the SSH key pair to use"
  type        = string
  default     = "devops_keypair"
}
