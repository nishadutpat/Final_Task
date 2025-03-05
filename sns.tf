

resource "aws_sns_topic" "email_notifications" {
  name = "email-notifications"
}
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.email_notifications.arn
  protocol  = "email"
  endpoint  = "nishadutpat77@gmail.com"
}

resource "aws_iam_policy" "lambda_sns_policy_gdtc" {
  name        = "LambdaSNSPublishPolicygdtc"
  description = "Allows Lambda to publish to SNS"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = "arn:aws:sns:ap-south-1:703671922793:email-notifications"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_attach" {
  policy_arn = aws_iam_policy.lambda_sns_policy_gdtc.arn
  role       = aws_iam_role.lambda_glue_role_gdtc.name
}


