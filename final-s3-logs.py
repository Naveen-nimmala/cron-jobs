import boto3
import os
from pprint import pprint
import time

logs = boto3.client('logs')
ssm = boto3.client('ssm')

log_group_name = 'LOGGROUP_NAME'

def lambda_handler(event, context):
    export_to_time = int(round(time.time() * 1000))

    response = logs.create_export_task(
        logGroupName=log_group_name,
        fromTime=0,
        to=export_to_time,
        destination='devx-jekins',
        destinationPrefix=log_group_name.strip("/")
    )

lambda_handler('event', 'context')
