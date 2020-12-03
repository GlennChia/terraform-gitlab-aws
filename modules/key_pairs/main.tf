/**
* # Key Pairs module
**/

resource "tls_private_key" "this" {
  count = length(var.key_pairs)
  algorithm   = "RSA"
}

resource "aws_key_pair" "this" {
  count = length(var.key_pairs)

  key_name   = var.key_pairs[count.index]
  public_key = tls_private_key.this[count.index].public_key_openssh
}