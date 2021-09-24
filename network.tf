resource "aws_vpc" "main_vpc" {
  cidr_block = var.settings.vpc.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name =  "${var.settings.tag_prefix}_VPC"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.main_vpc.id
  availability_zone = "${var.settings.region}a"
  cidr_block = var.settings.subnet.cidr_block_a
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.settings.tag_prefix}_public_subnet_a"
  }

  depends_on = [aws_internet_gateway.prod_ig]
}
resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.main_vpc.id
  availability_zone = "${var.settings.region}b"
  cidr_block = var.settings.subnet.cidr_block_b
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.settings.tag_prefix}_public_subnet_b"
  }

   depends_on = [aws_internet_gateway.prod_ig]
}

resource "aws_internet_gateway" "prod_ig" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.settings.tag_prefix}_internet_gateway"
  }
}

resource "aws_route_table" "prod_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.prod_ig.id}"
      egress_only_gateway_id = ""
      ipv6_cidr_block = ""
      instance_id = ""
      local_gateway_id = ""
      nat_gateway_id = ""
      network_interface_id = ""
      transit_gateway_id = ""
      vpc_peering_connection_id = ""
      vpc_endpoint_id = ""
      carrier_gateway_id = ""
      destination_prefix_list_id = ""
    }
  ]

  tags = {
    Name = "${var.settings.tag_prefix}_igw_rt"
  }

   depends_on = [aws_internet_gateway.prod_ig]
}


resource "aws_route_table_association" "association_to_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.prod_rt.id
}

resource "aws_route_table_association" "association_to_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.prod_rt.id
}
