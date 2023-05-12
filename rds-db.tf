# Configuración de la instancia de con mysql 5.7.
resource "aws_db_instance" "rds_instance" {
  identifier             = "nb-rds-instance"
  db_name                = "nab_db"
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = var.my-db-password
  publicly_accessible    = false
  availability_zone      = "us-west-2b"
  db_subnet_group_name   = aws_db_subnet_group.main.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name = "RDS Instance"
  }
}