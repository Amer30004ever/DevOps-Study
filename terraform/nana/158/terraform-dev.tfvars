subnet_cidr_block = "10.0.50.0/24"
vpc_cidr_block = "10.0.0.0/16"
environment = "development"
cidr_blocks_1 = [ "10.0.0.0/16", "10.0.60.0/24"]  
cidr_blocks_2 = [
    {cidr_block = "10.0.0.0/16", name = "dev-vpc-5"}, #Attributes cidr_block,name
    {cidr_block = "10.0.60.0/24", name = "dev-subnet-5"}
]
