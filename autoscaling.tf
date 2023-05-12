# Creating the autoscaling launch configuration that contains AWS EC2 instance details
resource "aws_launch_configuration" "aws_autoscale_conf" {
  # Defining the name of the Autoscaling launch configuration
  name = "web_config"
  # Defining the image ID of AWS EC2 instance
  image_id = var.ec2_ami_id
  # Defining the instance type of the AWS EC2 instance
  instance_type = var.instance_type
  # Defining the Key that will be used to access the AWS EC2 instance
  key_name  = "kubernetes-lab"
  user_data = file("nginx-install.sh")
}

# Creating the autoscaling group within us-east-1a availability zone
resource "aws_autoscaling_group" "mygroup" {
  # Defining the availability Zone in which AWS EC2 instance will be launched
  availability_zones = ["us-west-2a", "us-west-2b"]
  # Specifying the name of the autoscaling group
  name = "autoscalegroup"
  # Defining the maximum number of AWS EC2 instances while scaling
  max_size = 4
  # Defining the minimum number of AWS EC2 instances while scaling
  min_size = 2
  # Grace period is the time after which AWS EC2 instance comes into service before checking health.
  health_check_grace_period = 30
  # The Autoscaling will happen based on health of AWS EC2 instance defined in AWS CLoudwatch Alarm 
  health_check_type = "EC2"
  # force_delete deletes the Auto Scaling Group without waiting for all instances in the pool to terminate
  force_delete = true
  # Defining the termination policy where the oldest instance will be replaced first 
  termination_policies = ["OldestInstance"]
  # Scaling group is dependent on autoscaling launch configuration because of AWS EC2 instance configurations
  launch_configuration = aws_launch_configuration.aws_autoscale_conf.name
}
# Creating the autoscaling schedule of the autoscaling group

# Creating the autoscaling policy of the autoscaling group
resource "aws_autoscaling_policy" "mygroup_policy_up" {
  name = "autoscalegroup_policy_up"
  # The number of instances by which to scale.
  scaling_adjustment = 1
  adjustment_type    = "ChangeInCapacity"
  # The amount of time (seconds) after a scaling completes and the next scaling starts.
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.mygroup.name
}
resource "aws_autoscaling_policy" "mygroup_policy_down" {
  name = "autoscalegroup_policy_dowm"
  # The number of instances by which to scale.
  scaling_adjustment = -1
  adjustment_type    = "ChangeInCapacity"
  # The amount of time (seconds) after a scaling completes and the next scaling starts.
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