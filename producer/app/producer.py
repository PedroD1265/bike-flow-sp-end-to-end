import json
import os
from datetime import datetime, timezone
from typing import Any

import requests
from dotenv import load_dotenv
from kafka import KafkaProducer
from kafka.admin import KafkaAdminClient, NewTopic
from kafka.errors import TopicAlreadyExistsError


load_dotenv()

GBFS_URL = os.getenv(
    "GBFS_URL",
    "https://saopaulo.publicbikesystem.net/customer/gbfs/v3.0/gbfs.json",
)
KAFKA_BROKER = os.getenv("KAFKA_BROKER", "localhost:9092")
TOPIC_STATION_INFORMATION = os.getenv(
    "KAFKA_TOPIC_STATION_INFORMATION",
    "station_information",
)
TOPIC_STATION_STATUS = os.getenv(
    "KAFKA_TOPIC_STATION_STATUS",
    "station_status",
)


def fetch_json(url: str) -> dict[str, Any]:
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response.json()


def get_feed_map(gbfs_root: dict[str, Any]) -> dict[str, str]:
    feeds = gbfs_root.get("data", {}).get("feeds", [])
    return {feed["name"]: feed["url"] for feed in feeds}


def get_stations(feed_payload: dict[str, Any]) -> list[dict[str, Any]]:
    return feed_payload.get("data", {}).get("stations", [])


def create_topics() -> None:
    admin = KafkaAdminClient(bootstrap_servers=KAFKA_BROKER, client_id="bikeflow-admin")

    existing_topics = set(admin.list_topics())

    topics_to_create = []
    for topic_name in [TOPIC_STATION_INFORMATION, TOPIC_STATION_STATUS]:
        if topic_name not in existing_topics:
            topics_to_create.append(
                NewTopic(name=topic_name, num_partitions=1, replication_factor=1)
            )

    if topics_to_create:
        try:
            admin.create_topics(new_topics=topics_to_create, validate_only=False)
            print(f"Created topics: {[topic.name for topic in topics_to_create]}")
        except TopicAlreadyExistsError:
            print("Topics already exist")
    else:
        print("Topics already exist, nothing to create")

    admin.close()


def build_producer() -> KafkaProducer:
    return KafkaProducer(
        bootstrap_servers=KAFKA_BROKER,
        key_serializer=lambda k: k.encode("utf-8"),
        value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    )


def enrich_record(record: dict[str, Any], feed_name: str) -> dict[str, Any]:
    return {
        "feed_name": feed_name,
        "ingested_at": datetime.now(timezone.utc).isoformat(),
        "payload": record,
    }


def publish_records(
    producer: KafkaProducer,
    topic: str,
    records: list[dict[str, Any]],
    feed_name: str,
) -> None:
    sent = 0

    for record in records:
        station_id = str(record.get("station_id", "unknown"))
        enriched = enrich_record(record, feed_name)

        producer.send(topic=topic, key=station_id, value=enriched)
        sent += 1

    producer.flush()
    print(f"Published {sent} records to topic '{topic}'")


def main() -> None:
    root = fetch_json(GBFS_URL)
    feed_map = get_feed_map(root)

    required_feeds = ["station_information", "station_status"]
    for feed_name in required_feeds:
        if feed_name not in feed_map:
            raise ValueError(f"Required feed '{feed_name}' not found")

    station_information = fetch_json(feed_map["station_information"])
    station_status = fetch_json(feed_map["station_status"])

    info_stations = get_stations(station_information)
    status_stations = get_stations(station_status)

    print(f"Resolved station_information URL: {feed_map['station_information']}")
    print(f"Resolved station_status URL: {feed_map['station_status']}")
    print(f"station_information records: {len(info_stations)}")
    print(f"station_status records: {len(status_stations)}")
    print()

    create_topics()

    producer = build_producer()
    try:
        publish_records(
            producer=producer,
            topic=TOPIC_STATION_INFORMATION,
            records=info_stations,
            feed_name="station_information",
        )
        publish_records(
            producer=producer,
            topic=TOPIC_STATION_STATUS,
            records=status_stations,
            feed_name="station_status",
        )
    finally:
        producer.close()


if __name__ == "__main__":
    main()