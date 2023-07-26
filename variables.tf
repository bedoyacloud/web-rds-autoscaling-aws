# Input Variables
variable "aws_region" {
  description = "Region in which AWS resources to be created"
  type        = string
  default     = "us-west-2"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-03f65b8614a860c29" # Amazon2 Linux AMI ID
}

variable "instance_ec2_type" {
  description = "EC2 type"
  type        = string
  default     = "t2.micro"
}

variable "client_name" {
  description = "Nombre del Cliente"
  type        = string
  default     = "pragma"
}

variable "project_name" {
  description = "Nombre del Proyecto"
  type        = string
  default     = "reto1"
}

variable "environment" {
  description = "Nombre del Ambiente"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Responsable del Proyecto"
  type        = string
  default     = "carlos.bedoya"
}

locals {
  client_name  = var.client_name
  project_name = var.project_name
  environment  = var.environment
  owner        = var.owner
}
