import boto3
from botocore.config import Config
import os

 
# Specify the regions to scan its log groups and set retention period for
# Valid values for REGIONS_TO_SCAN variable? Possible values are the regions’ codes, i.e., us-east-1, us-east-2, us-west-1
# regions = [item.strip() for item in os.environ['REGIONS_TO_SCAN'].split(",") if item] 
 
# # Specify the retention period in days
# # valid values? Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827,  2192, 2557, 2922, 3288, and 3653.
# RETENTION_PERIOD_IN_DAYS = int(os.environ.get('RETENTION_DAYS', 30))
RETENTION_PERIOD_IN_DAYS = 30
VALID_RETENTION_PERIOD_VALUES = [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 2192, 2557, 2922, 3288, 3653]

regions = ["eu-west-1", "eu-west-2"]

# Making sure we configure our boto3 client with a different Retry Configuration
custom_config = Config(
   retries = {
      'max_attempts': 10,
      'mode': 'adaptive'
   }
)
 
def lambda_handler():
    
    # test retention period for a valid value
    if RETENTION_PERIOD_IN_DAYS not in VALID_RETENTION_PERIOD_VALUES:
        return {'statusCode': 200, 'body': '`RETENTION_PERIOD_IN_DAYS` is set to `' + str(RETENTION_PERIOD_IN_DAYS) + '`. Valid values are  1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653.'}
    
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
            if 'retentionInDays' in group.keys():
                print(f"Retention is already set for {group['logGroupName']} LogGroup, {group['retentionInDays']} in {aws_region}")
                logGroupName=group['logGroupName']
            else:
                print(f"Retention is not set for {group['logGroupName']} LogGroup,in {aws_region}")
                setretention = client.put_retention_policy(
                    logGroupName=group['logGroupName'],
                    retentionInDays= RETENTION_PERIOD_IN_DAYS
                    )
                print(f"Retention updated for {logGroupName} Log Group with {RETENTION_PERIOD_IN_DAYS} days")
    
    return {'statusCode': 200, 'body': 'Process completed.'}

if __name__ == '__main__':
    lambda_handler()
