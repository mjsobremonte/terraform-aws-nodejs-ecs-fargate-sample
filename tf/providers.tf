provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

provider "docker" {
  registry_auth {
    address = local.aws_ecr_url
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}