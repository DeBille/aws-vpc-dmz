data "aws_region" "current" {}

data "aws_ami" "newest_ami" {
    owners = ["amazon"]
    most_recent = true
    name_regex = "amzn2-ami-hvm-2.0..*?-x86_64-gp2"
}
