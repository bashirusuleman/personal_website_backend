resource "aws_iam_role" "iam_lambda" {
  name               = "iam_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_lambda_function" "pageview_lambda" {
  s3_bucket     = aws_s3_bucket.S3_bucket_lambda.bucket
  s3_key        = "pageview/lambda_pageView.zip"
  function_name = var.pageview_Lambda
  role          = aws_iam_role.iam_lambda.arn
  handler       = "${var.pageview_Lambda}.lambda_handler"
  runtime       = "python3.8"
}


resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowGetFomS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pageview_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.S3_bucket_lambda.arn
}


resource "aws_cloudwatch_log_group" "pageview_cloudwatch" {
  name              = "/aws/lambda/${var.pageview_Lambda}"
  retention_in_days = 14
}

#AWS managed policy: For Lambda
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_pageView"
  path        = "/"
  description = "IAM policy for logging, Dynamodb Access from a lambda"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : "dynamodb:UpdateItem",
        "Resource" : "${aws_dynamodb_table.pageviews-dynamodb-table.arn}"


           },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "${aws_cloudwatch_log_group.pageview_cloudwatch.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
