

resource "aws_ecr_repository" "ecr_repo" {
  name = "glue"

  
}

resource "aws_ecr_repository" "lf2_repo" {
  name = "lambda"

  
}
