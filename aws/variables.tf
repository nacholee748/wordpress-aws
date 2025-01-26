variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "Project" {
  description = "Project Name"
  type = string
  default = "wordpress" 
}

variable "db_username" {}

variable "db_password" {}

variable "db_name" {}

variable "webapp_image" {
  description = "Docker image to run in the ECS cluster"
  default     = ""
}

variable "webapp_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "webapp_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}

variable "db_instance_class" {
  description = "The RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage for the RDS instance"
  type        = number
  default     = 20
}
