resource "random_password" "mlflow_backend_store" {
  length  = 16
  special = true

  # Added this because random password was generating a password that had chars that
  # aurora didnt allow. With the lifecycle this shouldnt impact existing passwords that
  # happened to generate ok.
  override_special = "_+=()"
  lifecycle {
    ignore_changes = [override_special]
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.name}-rds-subnet-group2"
  subnet_ids = var.db_subnet_ids
}

resource "aws_security_group" "rds" {
  name   = "${var.name}-rds2"
  vpc_id = var.vpc_id
  tags   = var.tags

  ingress {
    from_port       = local.db_port
    to_port         = local.db_port
    protocol        = "tcp"
    security_groups = var.vpc_security_group_ids
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_rds_cluster" "mlflow_backend_store" {
  cluster_identifier        = "${var.name}-rds2"
  engine                    = "aurora-mysql"
  engine_version            = "5.7.mysql_aurora.2.07.1"
  engine_mode               = "serverless"
  port                      = local.db_port
  db_subnet_group_name      = aws_db_subnet_group.rds.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  availability_zones        = var.vpc-availability_zone_names
  database_name             = "mlflow"
  master_username           = "mlflow"
  master_password           = "mlflow_password"
  backup_retention_period   = 5
  preferred_backup_window   = "04:00-06:00"
  final_snapshot_identifier = "mlflow-db-backup"
  skip_final_snapshot       = var.db_skip_final_snapshot
  deletion_protection       = false
  apply_immediately         = true


  scaling_configuration {
    min_capacity             = var.db_min_capacity
    max_capacity             = var.db_max_capacity
    auto_pause               = var.db_auto_pause
    seconds_until_auto_pause = var.db_auto_pause_seconds
  }

}

# resource "aws_db_instance" "mlflow_backend_store" {
#   allocated_storage   = 50
#   identifier          = "rds-terraform"
#   storage_type        = "gp2"
#   engine              = "mysql"
#   engine_version      = "8.0.27"
#   instance_class      = "db.t2.micro"
#   name                = "mlflow"
#   username            = "mlflow"
#   password            = "mlflow_password"
#   publicly_accessible = true
#   skip_final_snapshot = true


#   tags = {
#     Name = "mlFlowServerInstance"
#   }
# }
