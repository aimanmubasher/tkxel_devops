provider "aws" 
{  
    region = "us-east-1"
    access_key = ""
    secret_key = ""
}
    
resource "aws_vpc" "devops_vpc" 
{    
    cidr_block = "20.0.0.0/32"
    tags = {
        Name = "DEVOPS"
    }
}
    
resource "aws_subnet" "devops_public_subnet" 
{
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = "20.0.0.0/32"
    
    tags = {
        Name = "DEVOPS_subnet"
    }
}

resource "aws_internet_gateway" "devops_igw" 
{
    vpc_id = aws_vpc.devops_vpc.id    
    tags = {
        Name = "DEVOPS_Internet_Gateway"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.devops_vpc.id  route 
    {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devops_igw.id
    }

    tags = {
        Name = "Devops_Public_RouteTable"
    }
}

resource "aws_route_table_association" "public_subnet_routetable_a" 
{
    subnet_id      = aws_subnet.devops_public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" 
{
    name   = "HTTP and SSH"
    vpc_id = aws_vpc.devops_vpc.id  
    
    ingress 
    {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress
    {
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

resource "aws_key_pair" "ec2_key_pair" 
{
    key_name = "assignmentkey"
    public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "web_instance" 
{  
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    ami = "ami-052387465d846f3fc"
    subnet_id = aws_subnet.devops_public_subnet.id

    vpc_security_group_ids = [aws_security_group.web_sg.id]
    
    associate_public_ip_address = true
    
    key_name = aws_key_pair.ec2_key_pair.key_name  
    tags = {
        Name = "EC2-instance"}
}

output "internet_gateway_id" 
{
    value = aws_internet_gateway.devops-igw.id
}

output "route_table_id" 
{
    value = aws_route_table.public_rt.id
}

output "security_group_id" 
{
    value = aws_security_group.devops_sg.id
}

output "instance_id" 
{
    value = aws_instance.devops-server.id
}

output "instance_public_ip" 
{
    value = aws_instance.devops-server.public_ip
}
