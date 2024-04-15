resource "aws_instance" "docker-host" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  key_name                    = aws_key_pair.key.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt update
              sudo apt install -y docker-ce docker-ce-cli containerd.io
              sudo groupadd docker
              sudo usermod -aG docker $USER
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo mkdir -p /home/ubuntu/.docker/cli-plugins/
              sudo curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o /home/ubuntu/.docker/cli-plugins/docker-compose
              sudo chmod +x /home/ubuntu/.docker/cli-plugins/docker-compose
              EOF

  depends_on = [aws_security_group.allow_ssh]
}

resource "null_resource" "docker-compose" {

  triggers = {
    id = aws_instance.docker-host.id
  }

  connection {
    agent       = "false"
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.key.private_key_pem
    host        = aws_instance.docker-host.public_ip
  }

  provisioner "file" {
    source      = "./docker-compose.yml"            # local Docker Compose dosyasının path
    destination = "/home/ubuntu/docker-compose.yml" # EC2 da kopyalanacak path
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sleep 90",
      "sudo chown ubuntu:ubuntu /var/run/docker.sock",
      "sudo chmod +x /home/ubuntu/docker-compose.yml",
      "docker compose up -d"
    ]
  }

  depends_on = [aws_instance.docker-host]
}
