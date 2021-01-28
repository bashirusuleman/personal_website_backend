provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

// S3 Bucket
resource "aws_s3_bucket" "S3_bucket" {
  bucket = var.s3_bucket_name


  website {
    index_document = "index.html"
    error_document = "error.html"
  }

   versioning {
    enabled = true
  }
}
// S3 object
//Cloudfront
//lambda
//DynamoDB
//API Gateway
//CodePipeline
//ACM
//Route 53


//Outputs

/* output "api_gateway_url" {
  value =
}
*/
output "S3website_url" {
  value = aws_s3_bucket.S3_bucket.website_domain
}