// S3 Bucket for Website
resource "aws_s3_bucket" "S3_bucket" {
  bucket = var.s3_bucket_name[0]
  acl    = "private"


  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  versioning {
    enabled = true
  }
}

// S3 Bucket for lambda
resource "aws_s3_bucket" "S3_bucket_lambda" {
  bucket = var.s3_bucket_name[1] 
  acl    = "private"

 versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "pageView_object" {
  bucket = aws_s3_bucket.S3_bucket_lambda.bucket
  key    = "pageview/lambda_pageView.zip"
  source = "./lambda_pageView.zip"
}