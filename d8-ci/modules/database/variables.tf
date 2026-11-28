variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  type = string
}

variable "db_instance_class" {
    type = string
}

variable "backup_retention_period" {
    type = number
}

variable "multi_az" {
    type = bool
}