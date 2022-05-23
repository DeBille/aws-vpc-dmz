variable "stack_name" {
  description = "Stack name to be used for tagging"
}

variable "vpc_cidr_head" {
  description = "Head (first two blocks) of the VPC CIDR range"
  default = "10.0"
}

variable "number_of_az" {
  description = "The number a Availability Zones. Depends on the region"
  default = 2
}

locals {
  common_tags = {"Stack": var.stack_name}
  az_zone_map = {
    0 = "a"
    1 = "b"
    2 = "c"
    3 = "d"
    4 = "e"
  }
}
