


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




//A module was used to implement ACM and Route53 validation
provider "aws" {
  region = "us-east-1"
  alias  = "certificates"
}

provider "aws" {
  region = "us-west-2"
  alias  = "dns"
}

data "aws_route53_zone" "domain_name" {
  name         = var.domain_name
}


module "certificate" {
  source = "github.com/azavea/terraform-aws-acm-certificate"

  providers = {
    aws.acm_account     = "aws.certificates"
    aws.route53_account = "aws.dns"
  }

  domain_name                       = var.domain_name
  subject_alternative_names         = ["*.${var.domain_name}"]
  hosted_zone_id                    = data.aws_route53_zone.domain_name.zone_id
  validation_record_ttl             = "60"
  allow_validation_record_overwrite = true
}


resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.domain_name.zone_id
  name    = "www.${data.aws_route53_zone.domain_name.name}"
  type    = "A"
    
   alias  {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}


//Route 53
#Using Data source to read the existing domain name in Route53.
#This was necessary to avoid charges creating hosted zone multiple times during terraform apply destroy process
#life-cycle rule can also be implemented as a work around
/* 



//ACM
resource "aws_acm_certificate" "certificate" {
  //Using a wildcard cert so that I can host subdomains later.
  domain_name       = "*.${var.root_domain}"
  validation_method = "DNS" //Email validation can be used however, this will be managed outside terraform

  // For the certificate to be valid for the route domain
  subject_alternative_names = [var.root_domain]

  lifecycle {
    create_before_destroy = true
  }
} */
//SES

//Terraform Graph--- Generate a terraform graph of the deployment

//Outputs

output "S3website_url" {
  value = aws_s3_bucket.S3_bucket.website_domain
}
output "dynamodb-arn" {
  value = aws_dynamodb_table.pageviews-dynamodb-table.arn
}

output "pageview_endpoint" {
  value = aws_api_gateway_deployment.pageview_deployment.invoke_url  
}