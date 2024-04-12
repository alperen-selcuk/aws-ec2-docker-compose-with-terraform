data "aws_availability_zones" "available" {
}

data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "random_id" "key" {
  byte_length = 8
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key" {
  key_name   = "devopsdude"
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.key.private_key_pem}" > aws_keys_pairs_${random_id.key.hex}.pem
      chmod 400 aws_keys_pairs_${random_id.key.hex}.pem
    EOT
  }
}
