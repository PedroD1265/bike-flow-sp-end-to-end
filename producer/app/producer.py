import json
from typing import Any

import requests

GBFS_URL = "https://saopaulo.publicbikesystem.net/customer/gbfs/v3.0/gbfs.json"


def fetch_json(url: str) -> dict[str, Any]:
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response.json()


def get_feed_map(gbfs_root: dict[str, Any]) -> dict[str, str]:
    feeds = gbfs_root.get("data", {}).get("feeds", [])
    return {feed["name"]: feed["url"] for feed in feeds}


def get_stations(feed_payload: dict[str, Any]) -> list[dict[str, Any]]:
    return feed_payload.get("data", {}).get("stations", [])


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

    print("Resolved feeds:")
    print(json.dumps(
        {
            "station_information": feed_map["station_information"],
            "station_status": feed_map["station_status"],
        },
        indent=2,
    ))
    print()

    print(f"station_information records: {len(info_stations)}")
    print(f"station_status records: {len(status_stations)}")
    print()

    if info_stations:
        print("station_information sample:")
        print(json.dumps(info_stations[0], indent=2)[:2000])
        print()

    if status_stations:
        print("station_status sample:")
        print(json.dumps(status_stations[0], indent=2)[:2000])


if __name__ == "__main__":
    main()