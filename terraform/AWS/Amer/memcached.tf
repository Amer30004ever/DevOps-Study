resource "aws_elasticache_cluster" "example" {
  # Required parameters
  cluster_id           = "cluster-example"  # Unique ID for the cache cluster
  engine               = "memcached"        # Engine type: memcached or redis
  node_type            = "cache.t3.micro"   # Free Instance type for cache nodes
  num_cache_nodes      = 2                  # Number of cache nodes

  # Optional parameters
  apply_immediately          = false        # Whether changes should be applied immediately or during maintenance window
  auto_minor_version_upgrade = true         # Enable/disable automatic minor version upgrades
  availability_zone         = null          # AZ where cache cluster will be created
  az_mode                   = "single-az"   # single-az or cross-az, only for memcached
  engine_version           = null           # Version number of the cache engine
  final_snapshot_identifier = null          # Final snapshot name when cluster is deleted (redis only)
  maintenance_window       = null           # Weekly time range for maintenance
  notification_topic_arn   = null          # ARN of SNS topic for notifications
  parameter_group_name     = "default.memcached1.4"  # Name of parameter group to associate
  port                     = 11211         # Port number for cache cluster
  preferred_availability_zones = []         # List of preferred AZs for cache nodes
  replication_group_id     = null          # ID of replication group to replicate with
  security_group_ids       = []            # List of security group IDs
  snapshot_arns           = []             # List of snapshot ARNs to restore from (redis only)
  snapshot_name           = null           # Name of snapshot to restore from (redis only)
  snapshot_retention_limit = 0             # Number of days to retain snapshots (redis only)
  snapshot_window         = null           # Daily time range for snapshots
  subnet_group_name       = null           # Name of subnet group to place cluster in
  tags                    = {}             # Map of tags to assign to resource

  # Timeouts for operations
  timeouts {
    create = "40m"
    delete = "40m"
    update = "40m"
  }
}
