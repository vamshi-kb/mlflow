variable "name" {
  description = "(Optional) Environment. It will be part of the application name and a tag in AWS Tags."
  type    = string
  default = "ai-ml-mlflow"
}

variable "environment" {
  description = "(Optional) Environment. It will be part of the application name and a tag in AWS Tags."
  type    = string
  default = "dev"
}

variable "iam_policies_arns"{
    type = list(string)
    default = ["arn:aws:iam::aws:policy/AmazonECS_FullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}

variable "aws_profile" {
  description = "(Optional) AWS profile to use. If not specified, the default profile will be used."
  type = string
  default = "default"
}

variable "aws_region" {
  description = "(Optional) AWS Region."
  type = string
  default = "eu-west-2" # i used my region here, you can replace with yours
}

variable "vpc_id" {
  type        = string
  description = "(Optional) VPC ID."
  default     = ""  # removed my vpc
}

variable "db_subnet_ids" {
  type        = list(string)
  default     = []  # remove subnets
  description = "List of subnets where the RDS database will be deployed"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "(Optional) Security group IDs to allow access to the VPC. It will be used only if vpc_id is set."
  default     = []  # removed security group
}

variable "vpc-cidr" {
  default = ""
  type    = string
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "vpc-availability_zone_names" {
  type    = list(string)
  default = []
}

variable "vpc-private-subnet-list" {
  type    = list(string)
  default = []
}

variable "vpc-public-subnet-list" {
  type    = list(string)
  default = []
}

variable "service_image_tag" {
  type        = string
  default     = "1.9.1"
  description = "The MLflow version to deploy. Note that this version has to be available as a tag here: https://hub.docker.com/r/larribas/mlflow"
}

variable "tags" {
  type = map(string)
  description = "(Optional) AWS Tags common to all the resources created."
  default = {}
}

variable "service_cpu" {
  type        = number
  default     = 1024
  description = "The number of CPU units reserved for the MLflow container."
}

variable "service_memory" {
  type        = number
  default     = 2048
  description = "The amount (in MiB) of memory reserved for the MLflow container."
}

variable "mlflow_username" {
  description = "Username used in basic authentication provided by nginx."
  type = string
  default = "mlflow"
}

variable "mlflow_password" {
  description = "Password used in basic authentication provided by nginx. If not specified, this module will create a strong password for you."
  type = string
  default = null
}

variable "mlflow_version" {
  description = "The mlflow-server version to use. See github.com/DougTrajano/mlflow-server for the available versions."
  type = string
  default = "latest"
}

variable "artifact_bucket_id" {
  type        = string
  default     = "mlflow-dev-processing"
  description = "If specified, MLflow will use this bucket to store artifacts. Otherwise, this module will create a dedicated bucket. When overriding this value, you need to enable the task role to access the root you specified."
}

variable "artifact_bucket_path" {
  type        = string
  default     = "/"
  description = "The path within the bucket where MLflow will store its artifacts"
}

variable "db_skip_final_snapshot" {
  type        = bool
  default     = false
  description = "(Optional) If true, this module will not create a final snapshot of the database before terminating."
}

variable "db_deletion_protection" {
  type        = bool
  default     = true
  description = "(Optional) If true, this module will not delete the database after terminating."
}

variable "db_instance_class" {
  type        = string
  default     = "db.t2.micro"
  description = "(Optional) The instance type of the RDS instance."
}

variable "db_auto_pause" {
  type        = bool
  default     = true
  description = "If true, the Aurora Serverless cluster will be paused after a given amount of time with no activity. https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html#aurora-serverless.how-it-works.pause-resume"
}

variable "db_auto_pause_seconds" {
  type        = number
  default     = 1800
  description = "The number of seconds to wait before automatically pausing the Aurora Serverless cluster. This is only used if rds_auto_pause is true."
}

variable "db_min_capacity" {
  type        = number
  default     = 2
  description = "The minimum capacity for the Aurora Serverless cluster. Aurora will scale automatically in this range. See: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html"
}

variable "db_max_capacity" {
  type        = number
  default     = 64
  description = "The maximum capacity for the Aurora Serverless cluster. Aurora will scale automatically in this range. See: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html"
}


variable "service_sidecar_container_definitions" {
  default     = []
  description = "A list of container definitions to deploy alongside the main container. See: https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html#container_definitions"
}