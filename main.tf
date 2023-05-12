variable "my-db-password" {

  type      = string
  sensitive = true
  default   = ""
}

### DATA MY IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}


# Configuración del VPC y la Subnet
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
}

####
#### SUBNETS 
####

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "us-west-2a"
}


resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_db_subnet_group" "main" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

######
###### Internet Gateway
#####


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


####
#### Elastic IP
####

resource "aws_eip" "main" {
  vpc = true
}


#####
##### Nat Gateway
#####

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public_subnet1.id


  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}


#####
##### Route tables
#####


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public_route"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private_route"
  }
}

resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "private-route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}


#####
##### ROUTE TABLE ASSOCIATIONS
#####

resource "aws_route_table_association" "public_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_association1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_association2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}




#####
##### 
#####

resource "aws_key_pair" "nab-key" {
  key_name   = "nab-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfCXhjoKb7JGQvM4Njp/S9Sg+C1GHvKVihqg8SELNjVYPTwYOqFNANRfBQ5guYoWwDH/2Pe2KSARMWCh/mNHfoxKAI65jC9wM4TNrPZw+REppoHADMdHIBxjLqOVNnfRyZk/PMu6NF6tAdLxAVzQeoNUihkuXGZP85Cbp6eHVtA5jlE8bZfkM56CdErVmfqkPf0bUu9GEJmMFdsgB3d7YywEsAuWJ2bp4sHUO5AUhkO7Jnoy8qZ74Ed987F5AdaDEvUZZKVCmpS2gFzU0bYlwilgMwyWZ61Vwi43QapllFe6x8bQW9t9QkU4ZOgLajiNGSjdE/tWtEjnb8ohgFbrql carloshernanbedoya@gmail.com"
}


# Configuración de la EC2
resource "aws_instance" "web_server" {
  ami                    = var.ec2_ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.nab-key.key_name
  user_data              = file("nginx-install.sh")

  tags = {
    Name = "Web Server" # Se puede cambiar el nombre según convenga. Esto solo es un tag
  }

  # # Activar el escalamiento basado en el uso de CPU usando stress
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get install -y stress",
  #     "while true; do stress --cpu 1 --timeout 300; done"
  #   ]
  # }

  #   # Política de AutoEscalado basado en la utlización de CPU aunque no estoy seguro si esto sigue usandose así o ahora se utiliza un nuevo recurso llamado aws_autoscaling_policy. Probar y en caso de algo lo pasamos a ese nuevo recurso
  #   scaling_policy {
  #     name                      = "scale-up"
  #     adjustment_type           = "ChangeInCapacity"
  #     scaling_adjustment        = 1
  #     cooldown                  = 300
  #     alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
  #     alarm_threshold           = 65
  #     alarm_evaluation_periods  = 2
  #     scale_in_cooldown         = 300
  #     scale_out_cooldown        = 300
  #     metric_aggregation_type   = "Average"
  #   }

  #   scaling_policy {
  #     name                      = "scale-down"
  #     adjustment_type           = "ChangeInCapacity"
  #     scaling_adjustment        = -1
  #     cooldown                  = 300
  #     alarm_comparison_operator = "LessThanOrEqualToThreshold"
  #     alarm_threshold           = 40
  #     alarm_evaluation_periods  = 2
  #     scale_in_cooldown         = 300
  #     scale_out_cooldown        = 300
  #     metric_aggregation_type   = "Average"
  #   }
}

resource "aws_lb" "nab_lb" {
  name            = "nab-load-balancer"
  subnets         = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups = [aws_security_group.web_sg.id]
  internal        = false

  tags = {
    Name = "Load Balancer"
  }
}

resource "aws_lb_target_group" "nab_target_group" {
  name        = "nab-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    protocol            = "HTTP"
    path                = "/"
  }
}

resource "aws_lb_listener" "nab_listener" {
  load_balancer_arn = aws_lb.nab_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.nab_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.nab_target_group.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}