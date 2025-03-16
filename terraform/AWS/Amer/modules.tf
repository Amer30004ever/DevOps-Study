module "company" {
    source = "./company"
    vpc = var.aws_vpc.ForgTech_vpc.id
    subnet = "10.0.0.0/24"
}

bucket_id = module.company.amer_bucket.id