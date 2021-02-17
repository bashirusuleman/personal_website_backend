import json
import boto3
import os
# from decimal import Decimal

def lambda_handler(event, context):
    # Initialize dynamodb boto3 object
    dynamodb = boto3.resource('dynamodb')
   
    table = dynamodb.Table('web-page-views')

    # Atomic update item in table or add if doesn't exist
    updateItem = table.update_item(
        Key={
            "ID": "count"
        },
        UpdateExpression='ADD pageviews :val',
        ExpressionAttributeValues={
            ':val': 1
        },
        ReturnValues="UPDATED_NEW"
    )

    # Format dynamodb response into variable
    responseBody = json.dumps(int(updateItem['Attributes']['pageviews']))
    

    # Create api response object
    return  {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": {"visitorsCount" :responseBody},
        "headers": {
            "Access-Control-Allow-Headers" : "Content-Type,X-Amz-Date,Authorization,X-Api-Key,x-requested-with",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,,OPTIONS" 
        },
    }