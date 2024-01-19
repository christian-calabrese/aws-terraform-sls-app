resource "aws_cloudwatch_metric_alarm" "api_gateway" {
  for_each            = { for alarm in var.api_gateway_metrics_to_alarm : alarm.metric_name => alarm }
  alarm_name          = "${var.project}-${var.environment}-api_gateway_${each.value}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/ApiGateway"
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = "Alarm for API Gateway ${each.key}"

  dimensions = {
    ApiName = aws_api_gateway_rest_api.notes_api.name
  }

  alarm_actions = [
    aws_sns_topic.alarm_notifications.arn
  ]
}

resource "aws_sns_topic" "alarm_notifications" {
  name = "${var.project}-${var.environment}-be-alarm-notifications"
}

resource "aws_sns_topic_subscription" "alarm_notifications_email" {
  for_each  = toset(var.support_email_list)
  topic_arn = aws_sns_topic.alarm_notifications.arn
  protocol  = "email"
  endpoint  = each.value
}
