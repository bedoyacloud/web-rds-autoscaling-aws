resource "aws_instance" "public" {
  ami                  = var.ami_id
  instance_type        = var.instance_ec2_type
  subnet_id            = aws_subnet.public_subnet1.id
  security_groups      = [aws_security_group.web_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ssm-ec2.name

  user_data = <<EOF
#!/bin/bash
apt update -y
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
sudo amazon-cloudwatch-agent-ctl -a start
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "Hello World from public $(hostname -f)" > /var/www/html/index.html
EOF


  tags = merge({
    "Name" = "${var.client_name}-${var.project_name}-${var.environment}-ec2-public-${var.owner}"
  })
}

resource "aws_instance" "private" {
  ami                  = var.ami_id
  instance_type        = var.instance_ec2_type
  subnet_id            = aws_subnet.private_subnet1.id
  security_groups      = [aws_security_group.ec2_internal_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ssm-ec2.name

  user_data = <<EOF
#!/bin/bash
apt update -y
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
sudo amazon-cloudwatch-agent-ctl -a start
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "Hello World from private $(hostname -f)" > /var/www/html/index.html
EOF


  tags = merge({
    "Name" = "${var.client_name}-${var.project_name}-${var.environment}-ec2-private-${var.owner}"
  })
}