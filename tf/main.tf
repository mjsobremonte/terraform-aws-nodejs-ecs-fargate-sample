## Create ECR Repository
resource "aws_ecr_repository" "repository" {
  name = "webapp-sample"
}

## Build docker images and push to ECR
resource "docker_registry_image" "webapp-sample" {
  name = "${aws_ecr_repository.repository.repository_url}:latest"

  build {
    context = "../webapp"
    dockerfile = "Dockerfile"
  }
}

## TODO: Create ECS instance and ALB