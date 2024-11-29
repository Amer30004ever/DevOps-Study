resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  #public_key = "ssh-rsa AAADSalaldASdlDSlASD2LkAS32D5l8kkjsdAL7SDoi6A5SDjl5S4DLKj21SDkj1 asds@gmail.com"
  #public_key = var.my_publick_key
  #public_key = file("id_rsa.pub")  #ssh-keygen to generate the key id_rsa.pub
  public_key = file(var.my_publick_key_location)
  #public_key = file("C:\\Users\\user\\Desktop\\id_rsa.pub") 
}