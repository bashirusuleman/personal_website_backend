#######################################################################
#######        API Gateway to Invoke Pageview lambda               ####
#######################################################################


resource "aws_api_gateway_rest_api" "pageView_api" {
  name = "pageview"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "pageView" {
  parent_id   = aws_api_gateway_rest_api.pageView_api.root_resource_id
  path_part   = "pageviews"
  rest_api_id = aws_api_gateway_rest_api.pageView_api.id
}

resource "aws_api_gateway_method" "pageview_method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.pageView.id
  rest_api_id   = aws_api_gateway_rest_api.pageView_api.id
}

resource "aws_api_gateway_integration" "pageview_lambda" {
  http_method = aws_api_gateway_method.pageview_method.http_method
  resource_id = aws_api_gateway_resource.pageView.id
  rest_api_id = aws_api_gateway_rest_api.pageView_api.id
  type        = "AWS"
  integration_http_method = "POST"
  uri = aws_lambda_function.pageview_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.pageView_api.id
  resource_id = aws_api_gateway_resource.pageView.id
  http_method = aws_api_gateway_method.pageview_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "pageViewIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.pageView_api.id
  resource_id = aws_api_gateway_resource.pageView.id
  http_method = aws_api_gateway_method.pageview_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

}

resource "aws_api_gateway_deployment" "pageview_deployment" {
   rest_api_id = aws_api_gateway_rest_api.pageView_api.id
   depends_on = [aws_api_gateway_integration.pageview_lambda]
   stage_name  = "prod"
}

#Grant permission to API Gateway to invoke Lambda Function

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.pageview_Lambda
  principal     = "apigateway.amazonaws.com" 
  source_arn = "${aws_api_gateway_rest_api.pageView_api.execution_arn}/*/*/*"
}