
resource "aws_s3_bucket" "final-task" {
  bucket = "final-task-gdtc"
}


# bucket for athena 

resource "aws_s3_bucket" "athena-finaltask" {
  bucket = "athena-finaltask"
}


resource "aws_s3_bucket" "backend-terraform" {
  bucket = "terraform-backend-buck"
}

