variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "instance_count" {
  type    = number
  default = 3
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_key_name" {
  type        = string
  description = "Existing AWS key pair name"
  default     = "05Oct2024-Syd"
}

