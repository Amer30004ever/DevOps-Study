terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.18.0"
        }
    }
  
    #it's recommended to create a dedicated S3 bucket for storing Terraform state files
    # This helps with:
    # - State file isolation and organization
    # - Applying specific security controls and encryption
    # - Setting up proper access controls
    # - Enabling versioning for state file history
   backend "s3" {
        bucket = "backend_bucket" #bucket name
        key    = "terraform.tfstate" #the path where the state file will be stored in the S3 bucket
        region = "us-east-1"
    # While not strictly required, it's highly recommended to use a DynamoDB table for state locking
    # - State locking prevents concurrent state operations which could corrupt the state file
    # - The DynamoDB table provides distributed locking when multiple team members are working on the same Terraform configuration
        dynamodb_table = "backend_db_table" # Table must have a primary key named LockID
    } 
}


/*
example:
--------
  backend "s3" {
    bucket         	   = "mycomponents-tfstate"
    key              	   = "state/terraform.tfstate"
    region         	   = "eu-central-1"
    encrypt        	   = true
    dynamodb_table = "mycomponents_tf_lockid"
    #assume_role = {
    #  role_arn = "arn:aws:iam::PRODUCTION-ACCOUNT-ID:role/Terraform"
    #}
    #web_identity_token = "<token value>" #(Optional) File containing a web identity token from an OpenID Connect (OIDC) or OAuth provider
  }
*/
/*
#S3 Bucket Permissions
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mybucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::mybucket/path/to/my/key"
    }
  ]
}
*/

/*
#DynamoDB Table Permissions
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mybucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::mybucket/path/to/my/key"
    }
  ]
}
*/

/*
#Data Source Configuration
# This block retrieves the Terraform state from a remote S3 backend
# The terraform_remote_state data source allows reading state data from a remote backend
# backend = "s3" specifies we're using an S3 bucket as the remote backend
# config block contains the S3 bucket configuration:
#   - bucket: The name of the S3 bucket storing the state file
#   - key: The path to the state file within the bucket
#   - region: AWS region where the S3 bucket is located
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "backend_bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
*/

/*#output of (Data Source Configuration) be like this:
data.terraform_remote_state.network:
  id = 2016-10-29 01:57:59.780010914 +0000 UTC
  addresses.# = 2
  addresses.0 = 52.207.220.222
  addresses.1 = 54.196.78.166
  backend = s3
  config.% = 3
  config.bucket = terraform-state-prod
  config.key = network/terraform.tfstate
  config.region = us-east-1
  elb_address = web-elb-790251200.us-east-1.elb.amazonaws.com
  public_subnet_id = subnet-1e05dd33
*/