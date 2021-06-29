variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "common_tags" {
  description = "Tags for all resources"
  type        = map(string)
  default = {
    Project = "DevOpsLab"
  }
}
