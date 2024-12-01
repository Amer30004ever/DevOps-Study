#1#
resource "aws_instance" "app-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.app-subnet.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.availability_zone

    associate_public_ip_address = true
    #key_name = "ubuntu-key" # key name if created from console
    key_name = aws_key_pair.ssh-key.key_name # key name if created from terraform
    
    user_data = <<EOF
                #!/bin/bash
                sudo yum update -y && sudo yum install -y docker
                sudo systemctl start docker
                sudo usermod -aG docker ec2-user
                docker run -p 8080:80 nginx
                    EOF


    tags = {
        Name = "${var.env_prefix}-server"
    }

}

#2#
resource "aws_instance" "app-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.app-subnet.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.availability_zone

    associate_public_ip_address = true
    #key_name = "ubuntu-key" # key name if created from console
    key_name = aws_key_pair.ssh-key.key_name # key name if created from terraform
    
    user_data = file("entry-script.sh") 

    tags = {
        Name = "${var.env_prefix}-server"
    }

}

#3
resource "aws_instance" "bastion" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI in us-east-1
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private[0].id
  associate_public_ip_address = true
  security_groups = [aws_security_group.rds.id]
  tags           = local.common_tags

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y postgresql",
      "sudo yum install -y pgadmin4"
    ]
  }
}