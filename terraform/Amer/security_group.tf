#1#
resource "aws_security_group" "ForgTech_security_group" {
    name = "ForgTech_security_group"
    vpc_id = "aws_vpc.ForgTech_vpc.id"
    ingress {             # incomming traffic
    from_port = 0    # all ports          
    to_port = 0        # all ports                
    protocol = "-1"     # "-1" means all protocols (TCP, UDP, ..) 
    cidr_blocks = ["0.0.0.0/32"]  # Blocks all traffic by using a single host CIDR
  }
}

#2#
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
