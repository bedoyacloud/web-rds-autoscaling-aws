resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"  # 5 minutos (en segundos)
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Esta alarma se activa cuando el uso de CPU supera el 80% durante 5 minutos"
  alarm_actions       = [aws_sns_topic.bedoya_topic.arn]  # Aquí reemplaza con el ARN de tu topic de SNS
  dimensions = {
    InstanceId = aws_instance.public.id
  }
}

resource "aws_sns_topic" "bedoya_topic" {
  name = "BedoyaTopic"
}

resource "aws_sns_topic_subscription" "bedoya_subscription" {
  topic_arn = aws_sns_topic.bedoya_topic.arn
  protocol  = "email"
  endpoint  = "carlos.bedoya@pragma.com.co"  # Reemplaza con tu dirección de correo electrónico
}

# CloudWatch alarm for memory usage
resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  alarm_name          = "MemoryUsageAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"  # Adjust this threshold value as needed
  alarm_description   = "Memory usage is above 90% for 1 minute."
  alarm_actions       = [aws_sns_topic.bedoya_topic.arn]    # Add ARNs of actions to take when the alarm is triggered, e.g., notifying an SNS topic
  dimensions = {
    InstanceId = aws_instance.public.id
    ImageId = "${var.ami_id}"
    InstanceType = "${var.instance_ec2_type}"
  }
}

# CloudWatch alarm for Disk Read Ops
resource "aws_cloudwatch_metric_alarm" "DiskUsage" {
  alarm_name          = "DiskUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "50"  # Adjust this threshold value as needed
  alarm_description   = "Disk Read Ops  usage is above 10% for 6 minute."
  alarm_actions       = [aws_sns_topic.bedoya_topic.arn]    # Add ARNs of actions to take when the alarm is triggered, e.g., notifying an SNS topic
  dimensions = {
    path = "/"
    InstanceId = aws_instance.public.id
    ImageId = "${var.ami_id}"
    InstanceType = "${var.instance_ec2_type}"
    device = "xvda1"
    fstype = "ext4"
  }
}
