
resource "aws_lambda_function" "lambda_glue_insert_gdtc" {
  function_name = "lambda-glue-insert_gdtc"
  role          = aws_iam_role.lambda_glue_role_gdtc.arn
  package_type  = "Image"
  image_uri     = "703671922793.dkr.ecr.ap-south-1.amazonaws.com/glue:latest"
  timeout       = 60
  /*vpc_config {
    subnet_ids         = ["subnet-0153bd412dda5847f", "subnet-02f0e236b1390e48d"]  # Replace with your subnet IDs
    security_group_ids = ["sg-025812e0d2825aaf0"]  # Replace with your security group ID
  }*/
  environment {
    variables = {
      S3_BUCKET  = aws_s3_bucket.final-task.bucket
      GLUE_DB    = aws_glue_catalog_database.emp_detaill.name
 
    }
  }
}

# step fucntion 2
resource "aws_lambda_function" "lambda_glue_to_dynamo_gdtc" {
  function_name = "lambda-glue-to-dynamo-gdtc"
  role          = aws_iam_role.lambda_execution_role_gdtc.arn
  package_type  = "Image"
  image_uri     = "703671922793.dkr.ecr.ap-south-1.amazonaws.com/lambda:latest"
  timeout       = 60  
  /*handler       = "lambda_glue_to_dynamodb.lambda_handler"
  runtime       = "python3.9"*/
  

  environment {
    variables = {
      GLUE_DATABASE = "emp_detaill"
      GLUE_TABLE    = "emp_tabledata"
      DYNAMO_TABLE  = "TaskTablegdtc"
      SNS_TOPIC_ARN = "arn:aws:sns:ap-south-1:703671922793:email-notifications"  
    }
  }

 /* filename = "lambda_glue_to_dynamodb.zip"*/
}

# IAM 
resource "aws_iam_role" "lambda_glue_role_gdtc" {
  name = "lambda_glue_execution_role_gdtc"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "glue_s3_policy_gdtc" {
  name        = "GlueS3AccessPolicygdtc"
  description = "Allows Lambda to access Glue and S3"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"],
        Resource = ["${aws_s3_bucket.final-task.arn}/*", "${aws_s3_bucket.final-task.arn}"]
      },
      {
        Effect   = "Allow",
        Action   = ["glue:BatchCreatePartition", "glue:CreateTable", "glue:UpdateTable", "glue:GetTable", "glue:CreateDatabase"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
  role       = aws_iam_role.lambda_glue_role_gdtc.name
  policy_arn = aws_iam_policy.glue_s3_policy_gdtc.arn
}





resource "aws_iam_role" "lambda_execution_role_gdtc" {
  name = "lambda-execution-role-gdtc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy_gdtc" {
  name        = "LambdaPolicygdtc"
  description = "Allows Lambda to access Glue, DynamoDB, Athena, and SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["glue:GetTable", "glue:GetTables", "glue:GetDatabase"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = "arn:aws:sns:ap-south-1:703671922793:email-notifications"
      },
      # ✅ Add Athena permissions
      {
        Effect   = "Allow"
        Action   = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults"
        ]
        Resource = "*"
      },
      # ✅ Add S3 permissions for Athena query results
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::<athena-finaltask >",
          "arn:aws:s3:::<athena-finaltask >/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution_role_gdtc.name
  policy_arn = aws_iam_policy.lambda_policy_gdtc.arn
}