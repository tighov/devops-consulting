import boto3
from botocore.exceptions import ClientError
import json
import os

client = boto3.client("ses")
sender = os.environ["SENDER_EMAIL"]
sendto = os.environ["SENDTO_EMAIL"]
configset = os.environ["CONFIG_SET"]
domain_name = os.environ["DOMAIN_NAME"]
email_subject_prefix = os.environ["EMAIL_SUBJECT_PREFIX"]
charset = "UTF-8"


def lambda_handler(event, context):
    origin = event.get("headers", {}).get("origin", "")
    allowed_origins = [
        "https://www." + domain_name,
        "https://" + domain_name,
    ]
    cors_origin = origin if origin in allowed_origins else "https://www." + domain_name

    headers = {
        "Access-Control-Allow-Origin": cors_origin,
        "Access-Control-Allow-Methods": "POST,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    http_method = event.get("httpMethod", "")

    if http_method == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": headers,
            "body": json.dumps("OK"),
        }

    if http_method == "POST":
        return send_mail(event, headers)

    return {
        "statusCode": 405,
        "headers": headers,
        "body": json.dumps("Method Not Allowed"),
    }


def send_mail(event, headers):
    try:
        data = json.loads(event["body"])
        name = data["name"]
        email = data["email"]
        message = data.get("message", "")
        service = data.get("service", "General Inquiry")
        company = data.get("company", "N/A")
        budget = data.get("budget", "N/A")

        subject = f"{email_subject_prefix}{service} -- from {name}"
        content = (
            f"New booking request from DevOps Consulting website\n\r"
            f"\n\r---\n\r"
            f"\n\rName: {name}"
            f"\n\rEmail: {email}"
            f"\n\rCompany: {company}"
            f"\n\rService: {service}"
            f"\n\rBudget: {budget}"
            f"\n\r\n\rMessage:\n\r{message}"
        )

        response = client.send_email(
            Source=sender,
            Destination={"ToAddresses": [sendto]},
            Message={
                "Subject": {"Charset": charset, "Data": subject},
                "Body": {
                    "Html": {"Charset": charset, "Data": content},
                    "Text": {"Charset": charset, "Data": content},
                },
            },
        )
    except ClientError as e:
        print(e.response["Error"]["Message"])
        return {
            "statusCode": 501,
            "headers": headers,
            "body": json.dumps({"error": e.response["Error"]["Message"]}),
        }
    except (KeyError, json.JSONDecodeError) as e:
        return {
            "statusCode": 400,
            "headers": headers,
            "body": json.dumps({"error": f"Invalid request: {str(e)}"}),
        }

    print(f"Email sent! Message Id: {response['MessageId']}")
    return {
        "statusCode": 200,
        "headers": headers,
        "body": json.dumps({"message": "OK"}),
    }
