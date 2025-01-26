import boto3
import json

ecs_client = boto3.client('ecs')

def lambda_handler(event, context):
    cluster_name = event['queryStringParameters']['cluster']
    service_name = event['queryStringParameters']['service']
    
    try:
        # Trigger ECS task redeployment by updating the service with force-new-deployment
        response = ecs_client.update_service(
            cluster=cluster_name,
            service=service_name,
            forceNewDeployment=True
        )
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Redeployment triggered successfully', 'response': response})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }


# Test
# curl -X POST "https://your-api-id.execute-api.us-east-1.amazonaws.com/dev/redeploy?cluster=your-cluster-name&service=your-service-name"
# curl -X POST "https://h9dim8smk7.execute-api.us-east-1.amazonaws.com/dev/redeploy?cluster=ecs-cluster-wordpress&service=wordpress-app"
