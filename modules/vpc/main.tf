resource "aws_vpc" "this" {
  cidr_block = var.cidr

  tags = {
    Name = var.name
  }
}

output "vpc_id" {
  value = aws_vpc.this.id
}