from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from datetime import datetime

def print_message():
    print("Hola Nequi")

default_args = {
    'owner': 'airflow',  
    'depends_on_past': False, 
    'retries': 1,  
}

with DAG(
    dag_id='hola_nequi_dag', 
    default_args=default_args,
    description='Example DAG with Airflow',
    schedule_interval=None, 
    start_date=datetime(2023, 1, 1), 
    catchup=False,
) as dag:

    # Task 1: Start Dummy Task
    start_task = DummyOperator(
        task_id='start'
    )

    # Task 2: Python Function Task
    python_task = PythonOperator(
        task_id='print_message',
        python_callable=print_message
    )

    # Task 3: End Dummy Task
    end_task = DummyOperator(
        task_id='end'
    )

    # Set task dependencies
    start_task >> python_task >> end_task
