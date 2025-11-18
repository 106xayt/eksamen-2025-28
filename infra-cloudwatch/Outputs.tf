output "dashboard_name" {
  description = "Name of the created CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.sentiment_dashboard.dashboard_name
}

output "alarm_name" {
  description = "Name of the latency CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.latency_high.alarm_name
}

output "sns_topic_arn" {
  description = "SNS topic ARN used for alarm notifications"
  value       = aws_sns_topic.sentiment_alarm_topic.arn
}

