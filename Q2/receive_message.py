import boto3
import time
from datetime import datetime

def receive_message():
    sqs_client = boto3.client('sqs', region_name='us-east-1')
    s3_client = boto3.client('s3', region_name='us-east-1')
    queue_url = 'https://sqs.us-east-1.amazonaws.com/YOUR_ACCOUNT_ID/example-queue'
    s3_bucket = 'Assessment-bucket'

    while True:
        response = sqs_client.receive_message(
            QueueUrl=queue_url,
            MaxNumberOfMessages=1,
            WaitTimeSeconds=20,
        )
        
        if 'Messages' in response:
            for message in response['Messages']:
                body = message['Body']
                receipt_handle = message['ReceiptHandle']
                
                timestamp = datetime.utcnow().strftime('%Y-%m-%d-%H:%M:%S')
                filename = f"{timestamp}-message.log"
                
                with open(filename, 'w') as file:
                    file.write(body)
                
                s3_client.upload_file(filename, s3_bucket, filename)
                
                sqs_client.delete_message(
                    QueueUrl=queue_url,
                    ReceiptHandle=receipt_handle
                )
        time.sleep(5)

if __name__ == "__main__":
    receive_message()
