variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "ca-central-1"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
}

variable "prefix" {
  description = "Prefix all resources created"
  default     = "terraform-sample"
}

variable "ingress_from_port" {
  default     = 80
}

variable "ingress_to_port" {
  default     = 80
}
