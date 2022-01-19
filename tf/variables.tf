variable "aws_region" {
  description = "AWS region to create resources in"
  type = string
  default = "ca-central-1"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type = string
}