provider "aws" {}

variable "cidr_blocks_vpc" {}
variable "cidr_blocks_subnet" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable my_publick_key_location {}

resource "aws_vpc" "app-vpc" {
  cidr_block = var.cidr_blocks_vpc
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "app-subnet" {
  vpc_id = aws_vpc.app-vpc.id
  cidr_block = var.cidr_blocks_subnet
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

/*resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.app-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}*/

resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

/*resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.app-subnet.id
  route_table_id = aws_route_table.myapp-route-table.id
}*/

resource "aws_default_route_table" "main-rtb"  {
  default_route_table_id = aws_vpc.app-vpc.default_route_table_id  #to get 'default_route_table_id ' #.\terraform.exe state show aws_vpc.app-vpc

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}


/*resource "aws_security_group" "app-sg" {  #for custom security_group
  name = "app-sg"*/
resource "aws_default_security_group" "default-sg" {  
  vpc_id = aws_vpc.app-vpc.id
  
  ingress {                    # incomming traffic
    from_port = 22                #e.g #- SSH into EC2
    to_port = 22                       #- access from browser
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {                     
    from_port = 8080                
    to_port = 8080                      
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {                       # outgoing traffic
    from_port = 0                   #e.g - install tools and packages in EC2
    to_port = 0                         #- fetch Docker image, a request is sent to docker hub
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = [] #allows access to vpc
  }
  tags = {
    #Name = "${var.env_prefix}-sg"  #for custom security_group tag
    Name = "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
      name = "name" #the name of the filter is the name of the AMI argument, which is name
      values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}

/*output "aws_ami_id" {  # hash (resource "aws_instance" "app-server") and run terraform plan to test output
 #value = data.aws_ami.latest-amazon-linux-image #test without id to check resource details
  value = data.aws_ami.latest-amazon-linux-image.id #aws_ami_id = "ami-00ec1ed16f4837f2f", compare output with original latest
}*/

output "ec2_public_ip" {
  value = aws_instance.app-server.public_ip
}
resource "aws_instance" "app-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.app-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.availability_zone

  associate_public_ip_address = true
  #key_name = "ubuntu-key" # key name if created from console
  key_name = aws_key_pair.ssh-key.key_name # key name if created from terraform
  
  /*user_data = <<EOF
            #!/bin/bash
            sudo yum update -y && sudo yum install -y docker
            sudo systemctl start docker
            sudo usermod -aG docker ec2-user
            docker run -p 8080:80 nginx
                EOF
  */
  user_data = file("entry-script.sh") 

  tags = {
    Name = "${var.env_prefix}-server"
  }

}


resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  #public_key = "ssh-rsa AAADSalaldASdlDSlASD2LkAS32D5l8kkjsdAL7SDoi6A5SDjl5S4DLKj21SDkj1 asds@gmail.com"
  #public_key = var.my_publick_key
  #public_key = file("id_rsa.pub")  #ssh-keygen to generate the key id_rsa.pub
  public_key = file(var.my_publick_key_location)
  #public_key = file("C:\\Users\\user\\Desktop\\id_rsa.pub") 
}