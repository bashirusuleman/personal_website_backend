provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

// S3 Bucket
resource "aws_s3_bucket" "S3_bucket" {
  bucket = var.s3_bucket_name
  acl = "private"


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

// S3 object
//Cloudfront
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Cloudfront OAI for S3 website Bucket"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.S3_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"



 // aliases = ["${var.s3_bucket_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", ]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_200"

  viewer_certificate {
    cloudfront_default_certificate = true
  }
 }


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
