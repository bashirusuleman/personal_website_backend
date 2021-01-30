


// S3 object
//Cloudfront


//To Allow cloudfront Origin access Identity to grant read permission to S3 website
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.S3_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.S3_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}




//lambda
//DynamoDB
resource "aws_dynamodb_table" "page-dynamodb-table" {
  name           = "Web-page-view"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}

//API Gateway
//CodePipeline
//ACM
//Route 53
//SES

//Terraform Graph--- Generate a terraform graph of the deployment

//Outputs

/* output "api_gateway_url" {
  value =
}
*/
output "S3website_url" {
  value = aws_s3_bucket.S3_bucket.website_domain
}
output "dynamodb-arn" {
  value = aws_dynamodb_table.page-dynamodb-table.arn
}
