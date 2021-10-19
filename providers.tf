provider "aws" {
  region = var.region
}

/*
terraform {
  backend "s3" {
    bucket = "learning-terraform-iac-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  } 
}
*/

# ресурсы, необходимые для хранения состояний терраформ, чтобы была возможность
# откатываться на предыдущие состояния, если вдруг ошибка или повреждение
# S3 bucket & DynamoDB table (locks)
#
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket

  lifecycle {
    prevent_destroy = false
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    } 
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S" 
  }
}