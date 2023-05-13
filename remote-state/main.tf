resource "aws_s3_bucket" "remote-state" {
  bucket = "terraform-remote-state-abc123abc"
}

resource "aws_dynamodb_table" "state-lock" {
  name           = "terraform-remote-state"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}