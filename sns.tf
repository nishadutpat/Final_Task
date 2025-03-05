

resource "aws_sns_topic" "email_notifications" {
  name = "email-notifications"
}
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.email_notifications.arn
  protocol  = "email"
  endpoint  = "nishadutpat77@gmail.com"
}



