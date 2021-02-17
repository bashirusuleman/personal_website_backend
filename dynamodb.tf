resource "aws_dynamodb_table" "pageviews-dynamodb-table" {
  name           = "web-page-views"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  } 

  }