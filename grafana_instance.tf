resource "aws_instance" "grafana_server" {
  ami             = "ami-005e54dee72cc1d00" 
  instance_type   = var.instance_type
  # key_name        = var.instance_key
  subnet_id       = aws_subnet.private.id
#   security_groups = [aws_security_group.sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing Grafana"
  sudo apt update
  sudo apt-get install -y apt-transport-https software-properties-common wget
  sudo apt update
  sudo mkdir -p /etc/apt/keyrings/
  sudo su
  wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor > /etc/apt/keyrings/grafana.gpg
  echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list
  sudo apt-get update
  sudo apt-get install grafana -y
  systemctl start grafana-server
  exit;
  echo "grafana installed"
  S3_BUCKET="grafana-json-collector"
  
 EOF

  tags = {
    Name = "private_grafana_instance"
  }

  volume_tags = {
    Name = "grafana_instance"
  } 
}