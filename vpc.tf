provider "aws" {
 region    =  "ap-south-1"
 profile   =   "rajat"
}


resource "aws_vpc" "myteravpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  

  tags = {
    Name = "myteravpc"
  }
}

resource "aws_subnet" "Pub_subnet"{
  vpc_id  =  "vpc-0af147b0799765383"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"


 tags = {
   Name = "publicsubnet-1a"
  }
}

resource "aws_subnet" "pri_subnet" {
  vpc_id  =  "vpc-0af147b0799765383"
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1b"


  tags = {
    Name = "privatesubnet-1b"
  }
}



resource "aws_security_group" "security" {
  name        = "mysecurity"
  description = "Allow inbound traffic"
  vpc_id = "vpc-0af147b0799765383"


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TCP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow Mysql"
  vpc_id      = "vpc-0af147b0799765383"

   ingress {
    description = "TCP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_only_mysql"
  }
}



resource "aws_internet_gateway" "myteravpcIGW" {
  vpc_id = "vpc-0af147b0799765383"

  tags = {
    Name = "myteravpcIGW"
  }
}



resource "aws_route_table" "mytera_vpc_route_table" {
  vpc_id = "vpc-0af147b0799765383"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-047fe3da3c5263f69"
  }
  tags = {
   Name = "myteraroutetable"
  }
}



resource "aws_instance" "myos1" {
	ami = "ami-052c08d70def0ac62"
	instance_type = "t2.micro"
        key_name = "mykey1111"
	vpc_security_group_ids = [aws_security_group.security.id]
    subnet_id = "${aws_subnet.Pub_subnet.id}"
  
tags = {
	Name = "WPOS"
	}
   }


resource "aws_instance" "myos2" {
	ami = "ami-08706cb5f68222d09"
	instance_type = "t2.micro"
        key_name = "mykey1111"
	vpc_security_group_ids = [aws_security_group.allow_mysql.id]
    subnet_id = "${aws_subnet.pri_subnet.id}"
  
tags = {
	Name = "MYSQL"
	}
   }
