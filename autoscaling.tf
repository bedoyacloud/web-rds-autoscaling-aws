resource "aws_launch_configuration" "aws_autoscale_conf" {
  name_prefix   = "web-config-"
  image_id      = var.ec2_ami_id
  instance_type = var.instance_ec2_type
  key_name      = "kubernetes-lab"
  user_data     = file("nginx-install.sh")
  #security_groups = [aws_security_group.web_sg.id]
}

# resource "aws_autoscaling_attachment" "autoscaling_attachment" {
#   autoscaling_group_name = aws_autoscaling_group.mygroup.id
#   lb_target_group_arn = aws_lb_target_group.nab_target_group.id
#   }

# Creating the autoscaling group within us-east-1a availability zone
resource "aws_autoscaling_group" "mygroup" {
  availability_zones        = ["us-west-2a", "us-west-2b"]
  name                      = "autoscalegroup"
  max_size                  = 4
  min_size                  = 2
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  launch_configuration      = aws_launch_configuration.aws_autoscale_conf.name
  # target_group_arns    = [aws_lb_target_group.nab_target_group.id]
}

resource "aws_autoscaling_policy" "mygroup_policy_up" {
  name                   = "autoscalegroup_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.mygroup.name
}
resource "aws_autoscaling_policy" "mygroup_policy_down" {
  name                   = "autoscalegroup_policy_dowm"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.mygroup.name
}


# Creating the AWS CLoudwatch Alarm that will autoscale the AWS EC2 instance based on CPU utilization.
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  # defining the name of AWS cloudwatch alarm
  alarm_name          = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  # Defining the metric_name according to which scaling will happen (based on CPU) 
  metric_name = "CPUUtilization"
  # The namespace for the alarm's associated metric
  namespace = "AWS/EC2"
  # After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds and then autoscales
  period    = "60"
  statistic = "Average"
  # CPU Utilization threshold is set to 10 percent
  threshold = "65"
  alarm_actions = [
    "${aws_autoscaling_policy.mygroup_policy_up.arn}"
  ]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.mygroup.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  # defining the name of AWS cloudwatch alarm
  alarm_name          = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  # Defining the metric_name according to which scaling will happen (based on CPU) 
  metric_name = "CPUUtilization"
  # The namespace for the alarm's associated metric
  namespace = "AWS/EC2"
  # After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds and then autoscales
  period    = "60"
  statistic = "Average"
  # CPU Utilization threshold is set to 10 percent
  threshold = "40"
  alarm_actions = [
    "${aws_autoscaling_policy.mygroup_policy_down.arn}"
  ]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.mygroup.name}"
  }
}