

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Prefix used for all resource names"
  type        = string
  default     = "devops-assessment"
}

variable "environment" {
  description = "Deployment environment tag (e.g. dev / staging / prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type (t3.micro is free-tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 Key Pair for SSH access (leave empty to skip)"
  type        = string
  default     = ""
}

variable "app_version" {
  description = "Application version string returned by the /version endpoint"
  type        = string
  default     = "1.0.0"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block(s) allowed to SSH into the instance. Restrict in production!"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
