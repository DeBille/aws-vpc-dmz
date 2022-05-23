resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_head}.0.0/16"
  tags       = merge({ "Name" = var.stack_name }, local.common_tags)
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "${data.aws_region.current.name}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = { "Name" = var.stack_name }
  depends_on          = [aws_vpc.main]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.id
  depends_on      = [aws_vpc.main]
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge({ "Name" = var.stack_name }, local.common_tags)
}

# Subnets

resource "aws_subnet" "public_subnet" {
  count             = var.number_of_az
  cidr_block        = "${var.vpc_cidr_head}.${count.index + 1}1.0/24"
  vpc_id            = aws_vpc.main.id
  tags              = merge({ "Name" = "${var.stack_name}-public-az-${count.index + 1}" }, local.common_tags)
  availability_zone = "${data.aws_region.current.name}${local.az_zone_map[count.index]}"
}

resource "aws_subnet" "private_subnet" {
  count             = var.number_of_az
  cidr_block        = "${var.vpc_cidr_head}.${count.index + 1}2.0/24"
  vpc_id            = aws_vpc.main.id
  tags              = merge({ "Name" = "${var.stack_name}-private-az-${count.index + 1}" }, local.common_tags)
  availability_zone = "${data.aws_region.current.name}${local.az_zone_map[count.index]}"
}

# Routes

resource "aws_route_table" "public" {
  tags   = { "Name" : "${var.stack_name}-public" }
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_to_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
  depends_on             = [aws_route_table.public]
}

resource "aws_route_table_association" "public" {
  count = var.number_of_az
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table" "private" {
  tags   = { "Name" : "${var.stack_name}-private" }
  vpc_id = aws_vpc.main.id
}

# Note that this actually defines the private subnet as public. This is done to avoid extra costs of NAT Gateways.
# NAT Gateways should be used in real life

resource "aws_route" "private_to_igw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
  depends_on             = [aws_route_table.private]
}

resource "aws_route_table_association" "private" {
  count = var.number_of_az
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private_subnet[count.index].id
}

resource "aws_security_group" "allow_traffic_to_internet" {
  vpc_id = aws_vpc.main.id
  name = "${var.stack_name}-allow-traffic-to-internet"
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_traffic_from_vpc" {
  vpc_id = aws_vpc.main.id
  name = "${var.stack_name}-allow-from-vpc"
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

