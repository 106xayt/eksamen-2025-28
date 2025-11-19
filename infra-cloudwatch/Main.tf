//main
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_sns_topic" "sentiment_alarm_topic" {
  name = "${var.metrics_namespace}-sentiment-alarms"
}

resource "aws_sns_topic_subscription" "sentiment_alarm_email" {
  topic_arn = aws_sns_topic.sentiment_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}


resource "aws_cloudwatch_metric_alarm" "latency_high" {
  alarm_name          = "${var.metrics_namespace}-latency-high"
  alarm_description   = "Sentiment API latency (Average) > 5000 ms for at least 1 minute"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 5000                        # 5 sekunder


  metric_name         = "sentiment.analysis.duration.avg"
  namespace           = var.metrics_namespace
  statistic           = "Average"
  period              = 60                           # 60 s vindu
  treat_missing_data  = "notBreaching"


  dimensions = {
    candidate = var.candidate_dimension
  }

  alarm_actions = [aws_sns_topic.sentiment_alarm_topic.arn]
  ok_actions    = [aws_sns_topic.sentiment_alarm_topic.arn]
}


resource "aws_cloudwatch_dashboard" "sentiment_dashboard" {
  dashboard_name = "${var.metrics_namespace}-dashboard"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${var.metrics_namespace}",
            "sentiment.analysis.duration.avg",
            "candidate",
            "${var.candidate_dimension}",
            { "stat": "Average" }
          ]
        ],
        "region": "${var.aws_region}",
        "title": "Sentiment API latency (ms)",
        "yAxis": {
          "left": {
            "label": "Milliseconds"
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${var.metrics_namespace}",
            "sentiment.analysis.total.count",
            "candidate",
            "${var.candidate_dimension}",
            { "stat": "Sum" }
          ]
        ],
        "region": "${var.aws_region}",
        "title": "Number of analyses (sum per minute)"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 6,
      "height": 3,
      "properties": {
        "view": "singleValue",
        "metrics": [
          [
            "${var.metrics_namespace}",
            "sentiment.analysis.companies.detected.value",
            "candidate",
            "${var.candidate_dimension}",
            { "stat": "Maximum" }
          ]
        ],
        "region": "${var.aws_region}",
        "title": "Companies detected (last run)"
      }
    }
  ]
}
EOF
}
