resource "aws_sfn_state_machine" "first_step_function_gdtc" {
  name     = "first-step-function-gdtc"
  role_arn = aws_iam_role.step_function_role_gdtc.arn

  definition = jsonencode({
    Comment = "First Step Function to process S3 file and insert into Glue Table"
    StartAt = "ProcessFile"
    States = {
      ProcessFile = {
        Type     = "Task"
        Resource = aws_lambda_function.lambda_glue_insert_gdtc.arn
        Next     = "TriggerStepFunction2"
      },
      TriggerStepFunction2 = {
        Type     = "Task"
        Resource = "arn:aws:states:::states:startExecution"
        Parameters = {
          StateMachineArn = "arn:aws:states:ap-south-1:703671922793:stateMachine:second-step-function-gdtc"
        }
        End = true
      }
    }
  })
}



resource "aws_iam_role" "step_function_role_gdtc" {
  name = "step-function-role-gdtc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_policy" "step_function_lambda_policy_gdtc" {
  name        = "StepFunctionLambdaPolicygdtc"
  description = "Allows Step Function 1 to invoke Lambda and start Step Function 2"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = aws_lambda_function.lambda_glue_insert_gdtc.arn
      },
      {
        Effect   = "Allow",
        Action   = "states:StartExecution",
        Resource = "arn:aws:states:ap-south-1:703671922793:stateMachine:second-step-function-gdtc"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "step_function_policy_attach" {
  role       = aws_iam_role.step_function_role_gdtc.name
  policy_arn = aws_iam_policy.step_function_lambda_policy_gdtc.arn
}



resource "aws_iam_role_policy_attachment" "step_function_lambda_policy_attach" {
  role       = aws_iam_role.step_function_role_gdtc.name
  policy_arn = aws_iam_policy.step_function_lambda_policy_gdtc.arn
}




# step  fucntion 2

resource "aws_sfn_state_machine" "second_step_function_gdtc" {
  name     = "second-step-function-gdtc"
  role_arn = aws_iam_role.step_function_2_role_gdtc.arn

  definition = jsonencode({
    Comment = "Step Function 2 to process Glue data, update DynamoDB, and send notification"
    StartAt = "ProcessGlueData"
    States = {
      ProcessGlueData = {
        Type     = "Task"
        Resource = aws_lambda_function.lambda_glue_to_dynamo_gdtc.arn
        End      = true
      }
    }
  })
}


resource "aws_iam_policy" "step_function_invoke_policy_gdtc" {
  name        = "StepFunctionInvokePolicygdtc"
  description = "Allows Step Function 1 to start Step Function 2"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "states:StartExecution",
        Resource = "arn:aws:states:ap-south-1:703671922793:stateMachine:second-step-function-gdtc"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_role_attachment" {
  role       = "step-function-role-gdtc"
  policy_arn = aws_iam_policy.step_function_invoke_policy_gdtc.arn
}



resource "aws_iam_role" "step_function_2_role_gdtc" {
  name = "step-function-2-role-gdtc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "step_function_2_policy_gdtc" {
  name = "StepFunction2Policygdtc"
  description = "Allows Step Function 2 to invoke Lambda and access Glue/DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = aws_lambda_function.lambda_glue_to_dynamo_gdtc.arn
      },
      {
        Effect = "Allow"
        Action = ["glue:GetTable", "glue:GetTables", "glue:GetDatabase"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = "arn:aws:dynamodb:ap-south-1:703671922793:table/TaskTable"
      },
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = "arn:aws:sns:ap-south-1:703671922793:email-notifications"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_2_policy_attach" {
  role       = aws_iam_role.step_function_2_role_gdtc.name
  policy_arn = aws_iam_policy.step_function_2_policy_gdtc.arn
}
