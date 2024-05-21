Build basic webserver running on ec2 


# Provder Configuration
provider "aws" { 
  region = "us-east-1"
}

#Create  security group to allow HTTP traffic
resource "aws_security_group" "web_sg" {
  name = "web_sg" 
  description = " Allow HTTP traffic"

#Ingress Rules to allow incoming HTTP traffic
  ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

# Egress rules to allow all outbound traffic
   egress {
      from_port    = 0
      to_port      = 0
      protocol     = "-1"
      cidr_blocks  = ["0.0.0.0/0"]
  }
}


# create EC2 instance
  resource "aws_instance" "web_server" {
    ami            = "ami-0bb84b8ffd87024d8"
    instance_ type = "t2.micro"

#add security group to instance
  security_group_ids = [aws_security_group.web_sg.id]

#Script to automate configuration tasks 
user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo amazon-linux-extras install nginx1 -y
  sudo systemctl start nginx
  sudo systemctl enable nginx
  echo "<html><body><h1>Hello World</h1></body></html>" . /usr/share/nginx/html/index.html
EOF
}

