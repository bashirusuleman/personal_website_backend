// S3 Bucket
resource "aws_s3_bucket" "S3_bucket" {
  bucket = var.s3_bucket_name # two S3 buckets for website  and another bucket to hold the lambda zip files
  #count  = length(var.s3_bucket_name)
  acl    = "private"


  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  versioning {
    enabled = true
  }
}

locals {
  s3_origin_id = "myS3Origin"
}