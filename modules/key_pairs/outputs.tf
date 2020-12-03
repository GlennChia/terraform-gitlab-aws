
output "private_keys" {
  value = [tls_private_key.this.*.private_key_pem]
}

output "public_keys" {
  value = [tls_private_key.this.*.public_key_pem]
}