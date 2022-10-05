import boto3
from botocore.config import Config
import os
import logging
import csv


# Appropriate logging
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
logging.getLogger('boto3').setLevel(logging.CRITICAL)
logging.getLogger('botocore').setLevel(logging.CRITICAL)


DEFAULT_RETENTION_PERIOD_IN_DAYS = 120
VALID_RETENTION_PERIOD_VALUES = [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 2192, 2557, 2922, 3288, 3653]

LOG_GROUPS = ["test"]
regions = ["eu-west-1"]

# Making sure we configure our boto3 client with a different Retry Configuration
custom_config = Config(
   retries = {
      'max_attempts': 10,
      'mode': 'adaptive'
   }
)


def lambda_handler(event, context):

    LOGGER.info(f"Regions to be scanned = {regions}")
    
    # test the regions 
    if not regions:
        return {'statusCode': 200, 'body': 'No regions found in `REGIONS_TO_SCAN` variable. Have you configured it?'}
    
    

    # Iterate through each region, setting boto3 client accordingly
    for aws_region in regions:
        client = boto3.client('logs',region_name=aws_region, config=custom_config)
        response = client.describe_log_groups()
        nextToken=response.get('nextToken',None)
        retention = response['logGroups']

        while (nextToken is not None):
            response = client.describe_log_groups(nextToken=nextToken)
            nextToken = response.get('nextToken', None)
            retention = retention.append(response['logGroups'])

        for group in retention:
            logGroupName=group['logGroupName']
            with open(r'data.csv') as read_obj: 
                csv_reader = csv.reader(read_obj)
                for row in csv_reader:
                    if logGroupName in row:
                        LOGGER.info(f"Retention is not set for {group['logGroupName']} LogGroup,in {aws_region}")
                        RETENTION_PERIOD_IN_DAYS = int(row[1]) if  len(row) > 1 else DEFAULT_RETENTION_PERIOD_IN_DAYS
                        if RETENTION_PERIOD_IN_DAYS not in VALID_RETENTION_PERIOD_VALUES:
                            return {'statusCode': 200, 'body': '`DEFAULT_RETENTION_PERIOD_IN_DAYS` is set to `' + str(RETENTION_PERIOD_IN_DAYS) + '`. Valid values are  1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653.'}
                        setRetention = client.put_retention_policy(
                            logGroupName=group['logGroupName'],
                            retentionInDays = RETENTION_PERIOD_IN_DAYS
                            )
                        LOGGER.info(f"Retention period to be set = {RETENTION_PERIOD_IN_DAYS}")   
                        LOGGER.info(f"Retention updated for {logGroupName} Log Group with {RETENTION_PERIOD_IN_DAYS} days")
    
    return {'statusCode': 200, 'body': 'Process completed.'}

lambda_handler("event", "context")
