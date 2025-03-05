resource "aws_cloudwatch_event_rule" "s3_event_rule_gdtc" {
  name        = "s3-upload-rule-gdtc"
  description = "Triggers Step Function when a new file is uploaded to S3"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["final-task-gdtc"]
    },
    "object": {
      "key": [{"prefix": "data/"}]  
    }
  }
}
EOF
}
resource "aws_cloudwatch_event_target" "trigger_step_function_gdtc" {
  rule      = aws_cloudwatch_event_rule.s3_event_rule_gdtc.name
  arn       = aws_sfn_state_machine.first_step_function_gdtc.arn
  role_arn  = aws_iam_role.eventbridge_role_gdtc.arn
}

resource "aws_iam_role" "eventbridge_role_gdtc" {
  name = "eventbridge-stepfunction-role-gdtc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "eventbridge_step_function_policy_gdtc" {
  name        = "eventbridge-stepfunction-policy-gdtc"
  description = "Allows EventBridge to start Step Function execution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "states:StartExecution"
        Resource = "arn:aws:states:ap-south-1:703671922793:stateMachine:first-step-function-gdtc"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_policy_attach" {
  policy_arn = aws_iam_policy.eventbridge_step_function_policy_gdtc.arn
  role       = aws_iam_role.eventbridge_role_gdtc.name
}


