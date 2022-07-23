resource "aws_iam_role" "ecs_task" {
  name = "${var.name}-ecs-task"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role" "ecs_execution" {
  name = "${var.name}-ecs-execution"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution.name
}


resource "aws_ecs_cluster" "main" {
  name = "mlflow-fargate-cluster"
}

data "template_file" "mlflow_app" {
  template = file("./templates/ecs/cb_app.json.tpl")

  vars = {
    name           = var.name
    app_image      = "intradiem/mlflow:mlflow_1.0"
    app_port       = 80
    fargate_cpu    = 1024
    fargate_memory = 2048
    aws_region     = var.aws_region

  }
}

resource "aws_ecs_task_definition" "mlflow" {
  family                   = "mlflow-task-app"
  task_role_arn            = aws_iam_role.ecs_task.arn
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode(concat([
    {
      name      = "mlflow-fargate"
      image     = "intradiem/mlflow:mlflow_1.0"
      essential = true

      # As of version 1.9.1, MLflow doesn't support specifying the backend store uri as an environment variable. ECS doesn't allow evaluating secret environment variables from within the command. Therefore, we are forced to override the entrypoint and assume the docker image has a shell we can use to interpolate the secret at runtime.
      entryPoint = ["sh", "-c"]
      command = [
        "/bin/sh -c \"mlflow server --host=0.0.0.0 --port=${local.service_port} --default-artifact-root=s3://${local.artifact_bucket_id}${var.artifact_bucket_path} --backend-store-uri=mysql+pymysql://${aws_rds_cluster.mlflow_backend_store.master_username}:${aws_rds_cluster.mlflow_backend_store.master_password}@${aws_rds_cluster.mlflow_backend_store.endpoint}:${aws_rds_cluster.mlflow_backend_store .port}/${aws_rds_cluster.mlflow_backend_store.database_name}\""
        # "/bin/sh -c \"mlflow server --host=0.0.0.0 --port=${local.service_port} --default-artifact-root=s3://${local.artifact_bucket_id}${var.artifact_bucket_path} --backend-store-uri=mysql+pymysql://${aws_db_instance.mlflow_backend_store.username}:${aws_db_instance.mlflow_backend_store.password}@${aws_db_instance.mlflow_backend_store.endpoint}:${aws_db_instance.mlflow_backend_store.port}/${aws_db_instance.mlflow_backend_store.name}\""
        #  "/bin/sh -c \"mlflow server --host=0.0.0.0 --port=${local.service_port}\""
      ]
      portMappings = [{ containerPort = local.service_port }]
      logConfiguration = {
        logDriver     = "awslogs"
        secretOptions = null
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.mlflow.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "cis"
        }
      }
    },
  ], var.service_sidecar_container_definitions))
}


# Service
resource "aws_ecs_service" "main" {
  name            = "mlflow-service"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.mlflow.family
  desired_count   = 10
  launch_type     = "FARGATE"
network_configuration {
    security_groups = var.vpc_security_group_ids
    subnets         = var.db_subnet_ids
    assign_public_ip = true
  }
load_balancer {
    target_group_arn = aws_alb_target_group.app.arn
    container_name   = "mlflow-fargate"
    container_port   = 80
  }
depends_on = [
    aws_ecs_task_definition.mlflow,aws_iam_role_policy_attachment.ecs_execution , aws_alb.main
  ]
}

resource "aws_cloudwatch_log_group" "mlflow" {
  name              = "/aws/ecs/${var.name}2"
  retention_in_days = 14
  tags              = var.tags
}