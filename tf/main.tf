##
## Create ECR Repository
##
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

##
## Setup LB
##
resource "aws_security_group" "lb" {
  name        = "${var.prefix}-lb-sg"
  description = "Controls access to the Application Load Balancer (ALB)"

  ingress {
    protocol    = "tcp"
    from_port   = var.lb_ingress_from_port
    to_port     = var.lb_ingress_to_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = "${var.prefix}-alb"
  subnets            = data.aws_subnet_ids.default.ids
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]

  tags = {
    Environment = var.ecs_environment
    Application = "${var.prefix}-webapp"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.prefix}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    matcher = "200-299"
    path    = "/"
  }
}

resource "aws_lb_listener" "listener_ffwd" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

##
## Setup ECS cluster, tasks, permissions and services
##
resource "aws_ecs_cluster" "cluster" {
  name = "${var.prefix}-webapp"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.prefix}-ecs-task-execution-role"
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
          "containerPort": ${var.ecs_container_port},
          "hostPort": ${var.ecs_host_port}
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
    protocol        = "tcp"
    from_port       = var.ecs_ingress_from_port
    to_port         = var.ecs_ingress_to_port
    security_groups = [aws_security_group.lb.id]
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
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.prefix}-webapp"
    container_port   = var.ecs_container_port
  }

  depends_on = [aws_lb_listener.listener_ffwd ,aws_iam_role_policy_attachment.ecs_task_execution_policy]

  tags = {
    Environment = var.ecs_environment
    Application = "${var.prefix}-webapp"
  }
}