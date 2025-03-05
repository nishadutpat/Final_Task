resource "aws_glue_catalog_database" "emp_detaill" {
  name = "emp_detaill"
}

resource "aws_glue_crawler" "crawler_gdtc" {
  name          = "crawler_gdtc"
  role          = aws_iam_role.glue_crawler_role_gdtc.arn  # Ensure this role has S3 & Glue permissions
  database_name = aws_glue_catalog_database.emp_detaill.name
  table_prefix  = "emp_table" # Prefix for tables created by the crawler

  s3_target {
    path = "s3://final-task-gdtc/data/"
  }



  configuration = jsonencode({
    Version = 1.0
    Grouping = { TableGroupingPolicy = "CombineCompatibleSchemas" }
  })
}


resource "aws_iam_role" "glue_crawler_role_gdtc" {
  name = "glue-crawler-role-gdtc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "glue_policy_gdtc" {
  name = "glue-crawler-policy_gdtc"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::final-task-gdtc",
          "arn:aws:s3:::final-task-gdtc/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["glue:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attach" {
  role       = aws_iam_role.glue_crawler_role_gdtc.name
  policy_arn = aws_iam_policy.glue_policy_gdtc.arn
}


