resource "aws_instance" "apache_instance" {
  ami             = "ami-005e54dee72cc1d00" 
  instance_type   = var.instance_type
  # key_name        = var.instance_key
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.sg.id]
  monitoring = true

 user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  sudo su
  echo "Welcome To CloudOps" > /var/www/html/index.html
  echo "*** Completed Installing apache2"
  exit;
  EOF
            
  tags = {
    Name = "Public_apache_instance"
  }


}
resource "aws_ebs_volume" "apache_ebs_volume" {
  availability_zone = aws_instance.apache_instance.availability_zone
  size              = 20  # Modify the size as needed
  encrypted         = true  # Ensure EBS volume is encrypted
}

resource "aws_volume_attachment" "apache_volume_attachment" {
  device_name = "/dev/sdh"  # Modify the device name as needed
  volume_id   = aws_ebs_volume.apache_ebs_volume.id
  instance_id = aws_instance.apache_instance.id
}