resource "aws_dynamodb_table" "task_table_gdtc" {
  name         = "TaskTablegdtc"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Remove this if not indexed:
  # attribute {
  #   name = "employee_count"
  #   type = "N"
  # }

  tags = {
    Name = "TaskTable"
  }
}


resource "aws_iam_role" "lambda_Dynamodb_role_gdtc" {
  name = "dynamodb_access_role_gdtc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "dynamodb_policy_gdtc" {
  name        = "DynamoDBAccessPolicygdtc"
  description = "Allows Lambda and Step Functions to access DynamoDB"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
          
        ]
        Resource = aws_dynamodb_table.task_table_gdtc.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_Dynamodb_role_gdtc.name
  policy_arn = aws_iam_policy.dynamodb_policy_gdtc.arn
}
