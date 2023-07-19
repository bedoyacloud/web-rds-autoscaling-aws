data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "public" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_ec2_type
  subnet_id = aws_subnet.public_subnet1.id
  security_groups = [aws_security_group.web_sg.id]

    user_data = <<EOF
#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "Hello World from public $(hostname -f)" > /var/www/html/index.html
EOF


  tags = merge({
    "Name" = "Public Instance"
  }, var.tags)
}

resource "aws_instance" "private" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_ec2_type
  subnet_id = aws_subnet.private_subnet1.id
  security_groups = [aws_security_group.ec2_internal_sg.id]

    user_data = <<EOF
#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "Hello World from private $(hostname -f)" > /var/www/html/index.html
EOF


  tags = merge({
    "Name" = "Private Instance"
  }, var.tags)
}