resource "aws_s3_bucket" "ForgTech_bucket" {
  bucket = var.bucket_name
  force_destroy = true  #force destroy even if bucket is not empty
  tags = {
    "Environment" = var.tags[0]
    "Owner"       = var.tags[1]
  }
}

# This configuration defines an S3 bucket and its lifecycle rules
# The main bucket resource with force_destroy enabled and environment/owner tags
resource "aws_s3_bucket" "ForgTech_bucket" {
  bucket = var.bucket_name
  force_destroy = true  #force destroy even if bucket is not empty
  tags = {
    "Environment" = var.tags[0]
    "Owner"       = var.tags[1]
  }
}

# Lifecycle configuration with 3 rules for different directories
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_1" {
  bucket = aws_s3_bucket.ForgTech_bucket.id
  
  # Rule 1: For /log directory
  # - Transitions objects through 3 storage classes over time
  # - Finally expires/deletes objects after specified days
  rule {
    id     = "ForgetTech_bucket_lifecycle_configuration_1"
    status = "Enabled"
    filter {
      prefix = "/log"  # Apply to /log directory
    }
    transition {
      days = var.transition.days[0]
      storage_class = var.transition.storage_class[0]
    }
    transition {
      days = var.transition.days[1]
      storage_class = var.transition.storage_class[1]
    }
    transition {
      days = var.transition.days[2]
      storage_class = var.transition.storage_class[2]
    }
    expiration {  #Remove files after 365 days
      days = var.transition.days[3]
    }
  }

  # Rule 2: For /outgoing directory
  # - Applies only to objects tagged with storage_class=notDeepArchive
  # - Transitions objects through 2 storage classes
  rule {
    id = "ForgetTech_bucket_lifecycle_configuration_2"
    status = "Enabled"
    filter {
      # The prefix parameter specifies a path prefix filter for the lifecycle rule
      # Objects with keys that begin with this prefix will be affected by this rule
      # For example, prefix = "/outgoing" means this rule applies to all objects in the /outgoing directory
      prefix = "/outgoing"  # Apply to /outgoing directory
      tag {
        key = "storage_class"
        value = "notDeepArchive"
      }
    }
    transition {
      days = var.transition.days[0]
      storage_class = var.transition.storage_class[0]
    }
    transition {
      days = var.transition.days[1]
      storage_class = var.transition.storage_class[1]
    }
  }

  # Rule 3: For /incoming directory
  # - Applies only to objects between 1MB and 1GB in size
  # - Transitions objects through 2 storage classes
  rule {
    id = "ForgetTech_bucket_lifecycle_configuration_3"
    status = "Enabled"
    filter {
      prefix = "/incoming" # Apply to /incoming directory
      object_size_greater_than = 1048576 # 1MB
      object_size_less_than = 1073741824 # 1GB
    }
    transition {
      days = var.transition.days[0]
      storage_class = var.transition.storage_class[0]
    }
    transition {
      days = var.transition.days[1]
      storage_class = var.transition.storage_class[1]
    }
  }
}

# Public access block configuration to secure the bucket
# Prevents any public access to the bucket contents
resource "aws_s3_bucket_public_access_block" "ForgTech_log_bucket_public_access" {
    bucket = aws_s3_bucket.ForgTech_log_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_1" {
  bucket = aws_s3_bucket.ForgTech_bucket.id
  # Rules for /log directory
  rule {
    id     = "ForgetTech_bucket_lifecycle_configuration_1"
    status = "Enabled"
    filter {
      prefix = "/log"  # Apply to /log directory
    }
    transition {
      days = var.transition.days[0]
      storage_class = var.transition.storage_class[0]
    }
    transition {
      days = var.transition.days[1]
      storage_class = var.transition.storage_class[1]
    }
    transition {
      days = var.transition.days[2]
      storage_class = var.transition.storage_class[2]
    }
    expiration {  #Remove files after 365 days
      days = var.transition.days[3]
    }
  }

  # Rules for /outgoing directory
  rule {
    id = "ForgetTech_bucket_lifecycle_configuration_2"
    status = "Enabled"
    filter {
      # The prefix parameter specifies a path prefix filter for the lifecycle rule
      # Objects with keys that begin with this prefix will be affected by this rule
      # For example, prefix = "/outgoing" means this rule applies to all objects in the /outgoing directory
      prefix = "/outgoing"  # Apply to /outgoing directory
      tag {
        key = "storage_class"
        value = "notDeepArchive"
      }
    }
    transition {
      days = var.transition.days[0]
      storage_class = var.transition.storage_class[0]
    }
    transition {
      days = var.transition.days[1]
      storage_class = var.transition.storage_class[1]
    }
  }

  # Rules for /incoming directory
  rule {
    id = "ForgetTech_bucket_lifecycle_configuration_3"
    status = "Enabled"
    filter {
      prefix = "/incoming" # Apply to /incoming directory
      object_size_greater_than = 1048576 # 1MB
      object_size_less_than = 1073741824 # 1GB
    }
    transition {
      days = var.transition.days[0]
      storage_class = var.transition.storage_class[0]
    }
    transition {
      days = var.transition.days[1]
      storage_class = var.transition.storage_class[1]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ForgTech_log_bucket_public_access" {
    bucket = aws_s3_bucket.ForgTech_log_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

