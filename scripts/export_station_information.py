import json
from datetime import datetime, timezone
from pathlib import Path

import requests

GBFS_URL = "https://saopaulo.publicbikesystem.net/customer/gbfs/v3.0/gbfs.json"


def fetch_json(url: str) -> dict:
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response.json()


def get_feed_map(gbfs_root: dict) -> dict[str, str]:
    feeds = gbfs_root.get("data", {}).get("feeds", [])
    return {feed["name"]: feed["url"] for feed in feeds}


def extract_localized_text(values, preferred_language="pt"):
    if not isinstance(values, list):
        return None
    for item in values:
        if item.get("language") == preferred_language:
            return item.get("text")
    return values[0].get("text") if values else None


def main() -> None:
    root = fetch_json(GBFS_URL)
    feed_map = get_feed_map(root)
    station_information = fetch_json(feed_map["station_information"])

    stations = station_information.get("data", {}).get("stations", [])
    ingested_at = datetime.now(timezone.utc).replace(microsecond=0).isoformat()

    snapshot_date = ingested_at[:10]
    snapshot_hour = ingested_at[11:13]

    output_dir = Path("data/raw/station_information") / f"snapshot_date={snapshot_date}" / f"snapshot_hour={snapshot_hour}"
    output_dir.mkdir(parents=True, exist_ok=True)

    output_file = output_dir / "station_information.ndjson"

    with output_file.open("w", encoding="utf-8") as f:
        for station in stations:
            record = {
                "station_id": station.get("station_id"),
                "external_id": station.get("external_id"),
                "station_name": extract_localized_text(station.get("name"), "pt"),
                "short_name": extract_localized_text(station.get("short_name"), "pt"),
                "lat": station.get("lat"),
                "lon": station.get("lon"),
                "address": station.get("address"),
                "capacity": station.get("capacity"),
                "is_charging_station": station.get("is_charging_station"),
                "is_virtual_station": station.get("is_virtual_station"),
                "ingested_at": ingested_at,
            }
            f.write(json.dumps(record, ensure_ascii=False) + "\n")

    print(f"Exported {len(stations)} records to {output_file}")


if __name__ == "__main__":
    main()
