import pika
import json
from src.x import generate_message

# Initialize the Hugging Face Transformer model

# Load the pipeline



# Function to process the message using Transformer model

# RabbitMQ configuration
generate_queue = "generate_queue"
response_queue = "response_queue"

# Connect to RabbitMQ
connection = pika.BlockingConnection(pika.URLParameters('amqp://guest:guest@localhost:5672/'))
channel = connection.channel()

channel.queue_declare(queue=generate_queue)
channel.queue_declare(queue=response_queue)

# Callback function to process messages from RabbitMQ
# Callback function to process messages from RabbitMQ
def callback(ch, method, properties, body):
    print("Received %r" % body)
    try:
        data = json.loads(body)

        # print("data received",data)
        appname = data['appname']
        severity = data['severity']
        task = data['message']
        try:
            response_data = generate_message(app=appname,task=task,severity=severity)
        except Exception as e:
            print("ERROR WITH GENERATE MESSAGE",e)
        try:

            channel.basic_publish(exchange='',
                              routing_key=response_queue,
                              body=response_data.encode())
        except Exception as e:
            print("ERROR publishing to notification queue",e)                                  

    except KeyError as e:
        print(f"Missing key in message: {e}")
    except Exception as e:
        print(f"Error processing message: {e}")


# Set up the consumer
channel.basic_consume(queue=generate_queue, on_message_callback=callback, auto_ack=True)

print('Waiting for messages. To exit press CTRL+C')
channel.start_consuming()
