resource "aws_instance" "ec2" {
  ami = var.ami
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  tags = {"Name": var.name}
  key_name = "bilit"
  user_data = <<EOT
#!/bin/bash
C=1; while [ $C -ne 0 ]; do timeout 5 curl -Ls www.google.com > /dev/null 2>&1; C=$?; sleep 5; done
yum update -y
echo "Userdata: Set hostname"
hostnamectl set-hostname ${var.name}

yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo "Hello World from ${var.name}" > /var/www/html/index.html
EOT
}