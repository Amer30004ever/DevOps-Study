
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