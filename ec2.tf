module "ec2_private" {
  count = var.number_of_az
  source = "./modules/ec2"
  ami                = data.aws_ami.newest_ami.id
  name               = "${var.stack_name}-private-a${count.index}"
  security_group_ids = [aws_security_group.allow_traffic_to_internet.id]
  subnet_id          = aws_subnet.private_subnet[count.index].id
}

module "ec2_public" {
  count = var.number_of_az
  source = "./modules/ec2"
  ami                = data.aws_ami.newest_ami.id
  name               = "${var.stack_name}-public-a${count.index}"
  security_group_ids = [aws_security_group.allow_traffic_to_internet.id, aws_security_group.allow_traffic_from_vpc.id]
  subnet_id          = aws_subnet.public_subnet[count.index].id
}