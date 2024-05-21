import boto3
from datetime import datetime

def publish_message():
    sns_client = boto3.client('sns', region_name='us-east-1')
    topic_arn = 'arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:example-topic'
    
    message = f"Hello server B from Server A at {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')}"
    
    sns_client.publish(
        TopicArn=topic_arn,
        Message=message
    )
    
if __name__ == "__main__":
    publish_message()
