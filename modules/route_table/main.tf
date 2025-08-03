resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.gateway_id != null ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.gateway_id
    }
  }

  dynamic "route" {
    for_each = var.nat_gateway_id != null ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.nat_gateway_id
    }
  }

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.main.id
}
