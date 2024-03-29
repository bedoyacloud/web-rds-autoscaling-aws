# Input Variables
variable "aws_region" {
  description = "Region in which AWS resources to be created"
  type        = string
  default     = "us-west-2"
}

variable "ec2_ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0ac64ad8517166fb1" # Amazon2 Linux AMI ID
}

variable "instance_ec2_type" {
  description = "EC2 type"
  type        = string
  default     = "t2.micro"

}

# variable "db_username" {
#   description = "AWS RDS Database Administrator Username"
#   type        = string
#   sensitive   = true
# }

# variable "db_paswword" {
#   description = "AWS RDS Database Administrator Password"
#   type        = string
#   sensitive   = true
# }

variable "tags" {
    description = "Project common tags"
    type = map(string)
    default = {
      "project" = "Terraform-challenge-bedoya"
      "owner" = "Bedoya-CloudOps"
    }
}