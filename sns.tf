resource "aws_sns_topic" "alert_sns" {
  name = "s3-upload-size-alert-sns"
}

resource "aws_sns_topic_subscription" "alert_subscription" {
  topic_arn = aws_sns_topic.alert_sns.arn
  protocol  = "email"
  endpoint  = "sc.bhuvanesh@gmail.com"  # Replace with your email address
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = aws_sns_topic.alert_sns.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}



data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect = "Allow"
    actions = ["SNS:Publish"]
    resources = ["${aws_sns_topic.alert_sns.arn}"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com","events.amazonaws.com","lambda.amazonaws.com"]
    }
    }
    }