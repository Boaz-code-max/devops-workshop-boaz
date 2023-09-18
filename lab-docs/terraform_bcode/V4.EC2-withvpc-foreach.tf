provider "aws" {
  region = "ap-south-1"
  
}

resource "aws_instance" "demo-server" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name = "Boaz"
  ##security_groups = ["demo-secgroup"]
  vpc_security_group_ids = [ aws_security_group.demo-secgroup.id ]
  subnet_id = aws_subnet.chinnusubnets-01.id
for_each = toset( ["Master Jenkines", "Build Jenkins", "Ansible",] )
  tags = {
    Name = "${each.key}"
  }
}

resource "aws_security_group" "demo-secgroup" {
  name        = "demo-secgroup"
  description = "ssh access"
  vpc_id = aws_vpc.chanduvpc.id 
  
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "jenkins port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "b-sg"
  }
}
resource "aws_vpc" "chanduvpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "chanduvpc"
  }
}

resource "aws_subnet" "chinnusubnets-01" {
  vpc_id     = aws_vpc.chanduvpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "chinnusubnets-01"
  }
  depends_on = [ aws_vpc.chanduvpc ]
}
resource "aws_subnet" "chinnusubnets-02" {
  vpc_id     = aws_vpc.chanduvpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "chinnusubnets-02"
  }
}
resource "aws_internet_gateway" "chandu-igw" {
  vpc_id = aws_vpc.chanduvpc.id
  tags = {
    Name = "chandu-igw"
  }
  
}
resource "aws_route_table" "chandu-rt" {
  vpc_id = aws_vpc.chanduvpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chandu-igw.id 
  }
  
}

resource "aws_route_table_association" "chandu-rta-1" {
  subnet_id = aws_subnet.chinnusubnets-01.id
  route_table_id = aws_route_table.chandu-rt.id 
  
}
resource "aws_route_table_association" "chandu-rta-2" {
  subnet_id = aws_subnet.chinnusubnets-02.id
  route_table_id = aws_route_table.chandu-rt.id
  
}