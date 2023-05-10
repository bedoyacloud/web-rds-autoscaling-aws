# Create Security Group - SSH Traffic
resource "aws_security_group" "web_sg" {
  name        = "SG-EC2-WebServer"
  description = "Security Group EC2 WebServer"
  vpc_id      = aws_vpc.main.id
  # Regla para permitir la entrada de tráfico solo desde la IP Pública del NAB. Los puertos también pueden ser cambiados si se requiere
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Reemplazar <NAB's Public IP> con el Public IP que se quiere usar
  }

  # Permitir el acceso SSH desde la IP propia (o la que se desee)
  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Reemplazar con la IP propia (o la que se desee)
  }

  # Permitir la salida de tráfico hacia internet
  egress {
    description = "Allow all IP and Ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "rds_sg" {
  name        = "SG-RDS-EC2"
  description = "Security Group from RDS to EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL traffic from only the web sg"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # egress {
  # from_port   = 0
  # to_port     = 0
  # protocol    = "-1"
  # cidr_blocks = ["0.0.0.0/0"]
  # }
}