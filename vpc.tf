provider "aws" {
  profile = "rajat"
  region = "ap-south-1"
}

#create key
resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHr1mQ8A39GTx7QmCfsKf7r4gmaf+4d4lv2HNGTqTLOAw0sES4qyprF91op7aAkXmHPZ+ww5Aa7tYBASMQYixXTuYrFKjW872usfpx26s6xjZZG2E/FnFpGqxgiCiNyCd682mwAPI9kJubcX+YtjHnFjFQ8ktjMH38pwzGAq2b4mFJJlfQKdfCiAk7d+K/eSnlBvdnJgnK/FUyCFkq9768s8q1juuCG4w+vX1Tcqieeo3k3I+UkZmAYx5dx9nibeQxOnFni/Imiscws+8C7YNkeJXquwAGmQ3bCQNtHa1DO7CTUlovR+jG7prgF5tIsgr8hvhRCA2sD7/5PTVlGXdNxadPHslvITJXwFY0wtRg20SA3NduVP6pQ/hoBHJJ+uWjih9dDHrcDx1DBvabMYS8hAdzf64sZFgNEEwonWEVGMXKNuBFpn7xAoWXxTSUqa1AJ85RWHAPdsOh537Azni5cLoUhHGuMHlOvAcG9b9kRNaIStFVBv91v/nUj5M3X6E= shelkevaishnavi0@gmail.com"
}

resource "aws_vpc" "mytaskvpc" {
  cidr_block = "192.168.0.0/16"


  tags = {
    Name = "mytaskvpc"
  }
}

resource "aws_subnet" "mypublicsubnet1" {
  vpc_id = "${aws_vpc.mytaskvpc.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"


  tags = {
    Name = "public subnet"
  }
}

resource "aws_subnet" "myprivatesubnet2" {
  vpc_id = "${aws_vpc.mytaskvpc.id}"
  cidr_block = "192.168.32.0/24"
  availability_zone = "ap-south-1b"


  tags = {
    Name = "private subnet"
  }
}

resource "aws_internet_gateway" "taskig" {
  vpc_id = "${aws_vpc.mytaskvpc.id}" 


  tags = {
    Name = "lwig"
  }
}

resource "aws_route_table" "taskroute" {
  vpc_id = "${aws_vpc.mytaskvpc.id}" 


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.taskig.id}"
  }


  tags = {
    Name = "lwrt3"
  }   
}

resource "aws_route_table_association" "mya" {
  subnet_id = aws_subnet.mypublicsubnet1.id
  route_table_id = aws_route_table.taskroute.id
}


resource "aws_route_table_association" "myb" {
  subnet_id = aws_subnet.myprivatesubnet2.id
  route_table_id = aws_route_table.taskroute.id
}


resource "aws_security_group" "task_sg1"{
  name = "task_sg1"
  vpc_id = "${aws_vpc.mytaskvpc.id}" 


  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 


  ingress {
    description = "TCP"
    from_port = 3306
    to_port = 3306
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
    Name = "lwsg3"
 }
}


resource "aws_instance" "public_subnet"{
  ami = "ami-96d6a0f9"
  instance_type = "t2.micro"
  key_name = "mykey"
  vpc_security_group_ids = [aws_security_group.task_sg1.id]
  subnet_id = "${aws_subnet.mypublicsubnet1.id}"


  tags = {
    Name = "task3wordpress"
  }
}

resource "aws_instance" "private_subnet"{
  ami = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name = "mykey"
  vpc_security_group_ids = [aws_security_group.task_sg1.id]
  subnet_id = "${aws_subnet.myprivatesubnet2.id}"


  tags = {
    Name = "task3mysql"
  }
}


