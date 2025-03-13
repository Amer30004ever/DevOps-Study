##1
resource "aws_mq_broker" "vprofile_mq" {
  broker_name = "vprofile_mq"
  engine_type    = "RabbitMQ"
  engine_version = "3.11.20"
  host_instance_type = "mq.t3.micro"
  security_groups    = [aws_security_group.vprofile_sg.id]

  user {
    username = "admin"
    password = "admin123"
  }
}

##2
resource "aws_mq_broker" "vprofile_mq" {
  # Required arguments
  broker_name = "vprofile_mq"
  engine_type = "RabbitMQ" # Valid values: ActiveMQ, RabbitMQ
  engine_version = "3.11.20"
  host_instance_type = "mq.t3.micro"
  
  # Optional arguments
  apply_immediately = false # Whether to apply updates immediately or during maintenance window
  authentication_strategy = "simple" # Authentication strategy - simple or ldap
  auto_minor_version_upgrade = true # Enables automatic upgrades to new minor versions
  deployment_mode = "SINGLE_INSTANCE" # SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, CLUSTER_MULTI_AZ
  encryption_options {
    kms_key_id = "" # ARN of KMS key to use for encryption
    use_aws_owned_key = true # Whether to use AWS owned KMS key
  }
  logs {
    general = false # Enable general logging
    audit = false # Enable audit logging 
  }
  maintenance_window_start_time {
    day_of_week = "MONDAY" # Day of week for maintenance
    time_of_day = "00:00" # Time of day in UTC
    time_zone = "UTC"
  }
  publicly_accessible = false # Whether broker should be publicly accessible
  security_groups = [aws_security_group.vprofile_sg.id]
  subnet_ids = [] # List of subnet IDs if running in VPC
  tags = {} # Resource tags

  user {
    username = "admin"
    password = "admin123"
    console_access = false # Whether to enable console access
    groups = [] # List of groups user belongs to
  }
}

##3
resource "aws_mq_configuration" "example" {
  name           = "example"
  engine_type    = "RabbitMQ"
  engine_version = "3.11.20"
  
  data = <<DATA
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<broker xmlns="http://activemq.apache.org/schema/core">
  <plugins>
    <authorizationPlugin>
      <map>
        <authorizationMap>
          <authorizationEntries>
            <authorizationEntry admin="admin" queue="&gt;" read="admin" write="admin"/>
            <authorizationEntry admin="admin" topic="&gt;" read="admin" write="admin"/>
          </authorizationEntries>
        </authorizationMap>
      </map>
    </authorizationPlugin>
  </plugins>
</broker>
DATA
}

resource "aws_mq_broker" "vprofile_mq" {
  broker_name = "vprofile_mq"
  
  configuration {
    id       = aws_mq_configuration.example.id
    revision = aws_mq_configuration.example.latest_revision
  }

  engine_type        = "RabbitMQ"
  engine_version     = "3.11.20"
  host_instance_type = "mq.t3.micro"
  security_groups    = [aws_security_group.vprofile_sg.id]

  auto_minor_version_upgrade = true
  deployment_mode           = "SINGLE_INSTANCE"
  publicly_accessible       = false
  subnet_ids               = [aws_subnet.private_1.id]

  maintenance_window_start_time {
    day_of_week = "MONDAY"
    time_of_day = "03:00"
    time_zone   = "UTC"
  }

  logs {
    general = true
    audit   = true
  }

  user {
    username = "admin"
    password = "admin123"
    console_access = true
  }

  tags = {
    Environment = "Production"
    Owner       = "DevOps Team"
  }
}