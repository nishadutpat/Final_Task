


provider "aws" {
  region     = "ap-south-1"
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

variable "AWS_ACCESS_KEY" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_KEY" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}




resource "aws_sns_topic" "email_notifications" {
  name = "email-notifications"
}
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.email_notifications.arn
  protocol  = "email"
  endpoint  = "nishadutpat77@gmail.com"
}



