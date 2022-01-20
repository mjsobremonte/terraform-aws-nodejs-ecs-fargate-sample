## Create ECR Repository
resource "aws_ecr_repository" "repository" {
  name = "${var.prefix}-webapp"
}

## Build docker images and push to ECR
resource "docker_registry_image" "registry_image" {
  name = "${aws_ecr_repository.repository.repository_url}:latest"

  build {
    context    = "../webapp"
    dockerfile = "Dockerfile"
  }
}

## Setup ECS cluster, tasks, permissions and services
resource "aws_ecs_cluster" "cluster" {
  name = "${var.prefix}-webapp"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs_taskdef" {
  family                   = "${var.prefix}-webapp"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.prefix}-webapp",
      "image": "${aws_ecr_repository.repository.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.prefix}-tasks-sg"
  description = "ECS Security Group"

  ingress {
    protocol    = "tcp"
    from_port   = var.ingress_from_port
    to_port     = var.ingress_to_port
    cidr_blocks = ["0.0.0.0/0"]
    # TODO   security_groups = [aws_security_group.lb.id] # setup lb
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "webapp" {
  name            = "${var.prefix}-ecs-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.ecs_taskdef.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = data.aws_subnet_ids.default.ids
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_policy]

  tags = {
    Environment = "test"
    Application = "${var.prefix}-webapp"
  }
}