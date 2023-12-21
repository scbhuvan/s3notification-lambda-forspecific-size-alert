import json
import urllib.parse
import boto3

s3 = boto3.client('s3')
sns = boto3.client('sns')

def limit_filename_length(filename, max_length=20):
    return filename[:max_length]

def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))

    # Get the object, Key and eventName from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = limit_filename_length(event['Records'][0]['s3']['object']['key'])
    eventname = event['Records'][0]['eventName']
    filesize = event['Records'][0]["s3"]["object"]["size"]
    sns_message = str(
        "A User has uploaded a file which size is more than 500GB\n\n"
        "BUCKET NAME: {}\nFILE NAME: {}\nOPERATION: {}\nFILE SIZE: {} bytes\n"
    ).format(bucket, key, eventname, filesize)
    subject = "S3 Bucket[{}] File[{}] Size[{} bytes]".format(bucket, key, filesize)
    try:
        if filesize > 1024:
            print('File uploaded on the Bucket "{}" & object "{}" is bigger than the specified size, Current file size is:"{}"'.format(bucket, key, filesize))
            sns_response = sns.publish(
            TargetArn='arn:aws:sns:eu-west-2:093308863220:s3-upload-size-alert-sns',
            Message= str(sns_message),
            Subject= str(subject)
            )
        else:
            print('File uploaded on the Bucket "{}" & object "{}" is smaller than the specified size, Current file size is:"{}"'.format(bucket, key, filesize))
    except Exception as e:
        print(e)
        print('Error on the Bucket "{}" & object "{}"'.format(bucket, key))
        raise e
    

    