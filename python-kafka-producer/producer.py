from confluent_kafka import Producer
import json
import time
import random
from datetime import datetime

# Kafka configuration
kafka_config = {
    'bootstrap.servers': 'localhost:9092',  # Replace with your Kafka broker address
    'client.id': 'python-events-producer',
}

# Initialize the producer
producer = Producer(kafka_config)

# Callback for delivery report
def delivery_report(err, msg):
    if err is not None:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}")

# Simulated user activity data
def generate_user_activity():
    return {
        "user_id": random.randint(1, 1000),
        "event_type": random.choice(["login", "logout", "purchase", "click"]),
        "timestamp": datetime.utcnow().isoformat(),
        "metadata": {
            "browser": random.choice(["Chrome", "Firefox", "Safari", "Edge"]),
            "device": random.choice(["Desktop", "Mobile", "Tablet"]),
        }
    }

# Main producer loop
if __name__ == "__main__":
    topic = "website-events"  # Replace with your Kafka topic name
    
    try:
        while True:
            # Generate a message
            message = generate_user_activity()
            
            # Produce message to Kafka
            producer.produce(
                topic=topic,
                key=str(message["user_id"]),
                value=json.dumps(message),
                callback=delivery_report
            )
            
            # Flush to ensure delivery
            producer.flush()
            
            # Wait for a while before sending the next message
            time.sleep(1)
    except KeyboardInterrupt:
        print("Producer stopped.")
    finally:
        producer.flush()
