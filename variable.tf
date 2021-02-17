variable "region" {
    type = string
}

variable "s3_bucket_name" {
    type = list(string)
    description = "List of S3 buckets for Website and to hold Lambda Code"
}

variable "pageview_Lambda" {
    type = string
    description = "Lambda Function name for Page view"
}