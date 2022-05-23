variable "ami" {
  description = "The AMI to use"
}

variable "name" {
  description = "name to be used for instance and role"
}

variable "subnet_id" {
  description = "Subnet to launch in"
}

variable "security_group_ids" {
  description = "Security groups to attach to instance"
  type = list(string)
}
