import pika
import json
from transformers import pipeline


# Initialize the Hugging Face Transformer model
model = pipeline('text-generation', model='gpt2')




# Function to process the message using Transformer model
def process_message(task):
    result = model(task, max_length=50)
    return result[0]['generated_text']

# RabbitMQ configuration
queue_name = "notification_queue"
response_queue = "response_queue"

# Connect to RabbitMQ
connection = pika.BlockingConnection(pika.URLParameters('amqp://guest:guest@localhost:5672/'))
channel = connection.channel()

channel.queue_declare(queue=queue_name)
channel.queue_declare(queue=response_queue)

# Callback function to process messages from RabbitMQ
# Callback function to process messages from RabbitMQ
def callback(ch, method, properties, body):
    print("Received %r" % body)
    try:
        data = json.loads(body)
        appname = data.get('appname')
        severity = data.get('severity')
        task = data.get('message')  # Use .get() to safely retrieve the value of 'task'

        task = task.replace("$(channel|country|state|live|title)", "")

        if appname is None or severity is None or task is None:
            raise KeyError("One or more required keys are missing in the message")

        prompt = f"Generate only one satirical notification with severity {severity} as user is using {appname} instead of {task} in 10 words"

        # Process the message using the Transformer model
        processed_message = process_message(prompt)

        print("Message is %", processed_message)

        response_data = json.dumps(processed_message)

        channel.basic_publish(exchange='',
                              routing_key=response_queue,
                              body=response_data)
        print("Sent %r" % response_data)

    except KeyError as e:
        print(f"Missing key in message: {e}")
    except Exception as e:
        print(f"Error processing message: {e}")


# Set up the consumer
channel.basic_consume(queue=queue_name, on_message_callback=callback, auto_ack=True)

print('Waiting for messages. To exit press CTRL+C')
channel.start_consuming()
