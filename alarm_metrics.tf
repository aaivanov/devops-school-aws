resource "aws_autoscaling_policy" "min_count_supprt" {
  name                   = "${var.settings.tag_prefix}_min_count_supprt"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.autoscaling_grp.name
}


resource "aws_autoscaling_policy" "min_count_supprt_1" {
  name                   = "${var.settings.tag_prefix}_min_count_supprt_1"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.autoscaling_grp.name
}


#resource "aws_cloudwatch_metric_alarm" "nlb_healthyhosts" {
#  alarm_name          = "${var.settings.tag_prefix}_alarm_elb"
#  comparison_operator = "LessThanThreshold"
#  evaluation_periods  = 2
#  metric_name         = "HealthyHostCount"
#  namespace           = "AWS/ELB"
#  period              = 60
#  statistic           = "Average"
#  threshold           = 2
#  actions_enabled     = "true"
#  dimensions = {
#    AvailabilityZone  = aws_elb.prod_lb.availability_zones
#    LoadBalancerName = aws_elb.prod_lb.name
#  }
#
#  alarm_description   = "Number of healthy nodes"
#  alarm_actions       = [aws_autoscaling_policy.min_count_supprt.arn]
#
#}


resource "aws_cloudwatch_metric_alarm" "bat" {
  alarm_name          = "${var.settings.tag_prefix}_cpu_l20"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_grp.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.min_count_supprt_1.arn]
}

resource "aws_cloudwatch_metric_alarm" "bat1" {
  alarm_name          = "${var.settings.tag_prefix}_cpu_o60"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_grp.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.min_count_supprt.arn]
}

