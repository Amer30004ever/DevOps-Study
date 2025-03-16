# Lookup the available instance classes for the custom engine for the region being operated in
# This data source looks up available RDS instance classes for PostgreSQL 15.x
# It specifically filters for db.t3.micro instance type which is suitable for dev/test
data "aws_rds_orderable_db_instance" "custom-oracle" {
  engine                     = "postgres" # CEV engine to be used
  engine_version             = "15.*"      # CEV engine version to be used
  #license_model              = "bring-your-own-license"
  #storage_type               = "gp3"
  preferred_instance_classes = ["db.t3.micro"]
}

# The RDS instance resource requires an ARN. Look up the ARN of the KMS key associated with the CEV.
data "aws_kms_key" "by_id" {
  key_id = "example-ef278353ceba4a5a97de6784565b9f78" # KMS key associated with the CEV
}

# Creates a PostgreSQL RDS database instance with the following configuration:
# - 20GB storage allocation
# - Uses subnet group defined elsewhere for networking
# - References engine and version details from the data source above
# - Single AZ deployment (no high availability)
# - Publicly accessible
# - Skips final snapshot on deletion
# - Tagged with Environment and Owner values
resource "aws_db_instance" "default" {
  allocated_storage           = 20
  #auto_minor_version_upgrade  = false                         # Custom for Oracle does not support minor version upgrades
  #custom_iam_instance_profile = "AWSRDSCustomInstanceProfile" # Instance profile is required for Custom for Oracle. See: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-setup-orcl.html#custom-setup-orcl.iam-vpc
  #backup_retention_period     = 7
  db_subnet_group_name        = aws_db_subnet_group.ForgTech_subnet_group.name
  engine                      = data.aws_rds_orderable_db_instance.custom-oracle.engine
  engine_version              = data.aws_rds_orderable_db_instance.custom-oracle.engine_version
  #identifier                  = "ee-instance-demo"
  instance_class              = data.aws_rds_orderable_db_instance.custom-oracle.preferred_instance_classes
  #kms_key_id                  = data.aws_kms_key.by_id.arn
  #license_model               = data.aws_rds_orderable_db_instance.custom-oracle.license_model
  multi_az                    = false # Custom for Oracle does not support multi-az
  #password                    = "avoid-plaintext-passwords"
  #username                    = "test"
  #storage_encrypted           = true
  publicly_accessible = true
  skip_final_snapshot = true

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
  tags = {
    "Environment" = var.tags.Environment
    "Owner" = var.tags.Owner
  }
}

#all attributes
resource "aws_db_instance" "name" {
    allocated_storage = 20
    engine = "postgres"
    engine_version = "15.3"
    instance_class = "db.t3.micro"
    username = "admin"
    password = "securepassword"
    skip_final_snapshot = true
    db_subnet_group_name = aws_db_subnet_group.default.name
    vpc_security_group_ids = [aws_security_group.rds.id]
    storage_encrypted = true
    publicly_accessible = false
    multi_az = true
    
    backup_retention_period = 7
    backup_window = "00:00-00:30"
    copy_tags_to_snapshot = true
    deletion_protection = true
    
    enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
    performance_insights_enabled = true
    
    performance_insights_retention_period = 7
    monitoring_interval = 60
    monitoring_role_arn = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    iam_database_authentication_enabled = true
    parameter_group_name = "default.postgres15"
    option_group_name = "default:postgres15"
    
    storage_type = "gp2"
    tags = {
        Name = "RDS"
    }

    
  
}