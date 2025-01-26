import boto3
import json
import time

ecs_client = boto3.client('ecs')

# Configuración global
MAX_RETRIES = 3
RETRY_DELAY = 10  # en segundos

def lambda_handler(event, context):
    # Extraer datos de la alerta de CloudWatch
    message = json.loads(event['Records'][0]['Sns']['Message'])
    cluster_name = message['AlarmName'].split('-')[1]  # Personaliza según el formato de la alarma
    service_name = message['AlarmName'].split('-')[2]  # Personaliza según el formato de la alarma

    try:
        # Obtener tareas en ejecución
        tasks = ecs_client.list_tasks(cluster=cluster_name, serviceName=service_name, desiredStatus='RUNNING')
        task_arns = tasks.get('taskArns', [])
        print(f"Found {len(task_arns)} tasks running for service {service_name}")

        if len(task_arns) >= 3:
            # Obtener detalles de las tareas para identificar la tarea "Unhealthy"
            task_descriptions = ecs_client.describe_tasks(cluster=cluster_name, tasks=task_arns)
            unhealthy_task_arn = None

            for task in task_descriptions['tasks']:
                if 'CPU' in task['overrides'] or 'Memory' in task['overrides']:  # Personaliza según métricas
                    unhealthy_task_arn = task['taskArn']
                    break

            if unhealthy_task_arn:
                # Matar la tarea no saludable
                ecs_client.stop_task(cluster=cluster_name, task=unhealthy_task_arn, reason="Unhealthy task detected")
                print(f"Stopped unhealthy task: {unhealthy_task_arn}")
        else:
            # Reintentar hasta lograr al menos 3 tareas en ejecución
            for attempt in range(MAX_RETRIES):
                tasks = ecs_client.list_tasks(cluster=cluster_name, serviceName=service_name, desiredStatus='RUNNING')
                task_arns = tasks.get('taskArns', [])
                if len(task_arns) >= 3:
                    print(f"Service recovered with {len(task_arns)} running tasks")
                    return {
                        'statusCode': 200,
                        'body': json.dumps({'message': 'Service recovered successfully'})
                    }
                print(f"Retry {attempt + 1}/{MAX_RETRIES} - Waiting for tasks to recover...")
                time.sleep(RETRY_DELAY)

            # Forzar un nuevo despliegue
            ecs_client.update_service(cluster=cluster_name, service=service_name, forceNewDeployment=True)
            print("Forced new deployment for the service")
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Lambda executed successfully'})
    }
