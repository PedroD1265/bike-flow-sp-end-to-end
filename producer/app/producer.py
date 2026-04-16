import json
import requests


GBFS_URL = "https://saopaulo.publicbikesystem.net/customer/gbfs/v3.0/gbfs.json"


def fetch_gbfs_root() -> dict:
    response = requests.get(GBFS_URL, timeout=30)
    response.raise_for_status()
    return response.json()


def main() -> None:
    data = fetch_gbfs_root()

    print("Top-level keys:")
    print(list(data.keys()))
    print()

    print("Raw response:")
    print(json.dumps(data, indent=2)[:4000])


if __name__ == "__main__":
    main()