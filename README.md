# Bike Flow SP End-to-End

End-to-end data engineering project for near-real-time bike station monitoring in São Paulo using GBFS, Redpanda, PyFlink, GCS, BigQuery, dbt, Kestra, and Looker Studio.

## Problem statement

This project monitors bike station availability in São Paulo to identify shortage, saturation, and operational imbalance patterns over time.

The goal is to build an end-to-end streaming data pipeline that ingests GBFS data, stores it in a data lake, loads it into a data warehouse, transforms it for analytics, and exposes it in a dashboard.

## Why this project

Urban bike-sharing systems generate near-real-time station status updates. These updates can be used to understand:

- which stations frequently run out of bikes
- which stations frequently run out of docks
- how station availability changes throughout the day
- which regions show stronger imbalance patterns

This makes the project a good real-world case for streaming ingestion, event processing, cloud storage, analytics engineering, and dashboarding.

## Dataset

Source: GBFS feed for São Paulo bike-sharing system.

Main feeds to be used:

- `station_information`
- `station_status`

## Architecture

GBFS São Paulo → Python Producer → Redpanda/Kafka → PyFlink → raw local → GCS → Kestra → BigQuery raw → dbt marts → Looker Studio

## Tech stack

- **Source:** GBFS São Paulo
- **Ingestion:** Python producer
- **Broker:** Redpanda / Kafka
- **Stream processing:** PyFlink
- **Orchestration:** Kestra
- **Data lake:** Google Cloud Storage
- **Data warehouse:** BigQuery
- **Transformations:** dbt
- **Dashboard:** Looker Studio
- **IaC:** Terraform

## Dashboard

Looker Studio dashboard: TODO: add public Looker Studio URL

Main dashboard views:

1. **Temporal view:** bike availability trend over time.
2. **Latest station view:** station-level bike and dock availability for the frozen delivery window.
3. **Risk view:** stations with higher bike shortage or dock saturation rates.

## Validated pipeline status

The current delivery path has been validated with the following successful steps:

- `upload_raw_to_gcs`: OK
- `load_raw_to_bigquery`: OK
- `dbt run`: PASS=11
- `dbt test`: PASS=31

Post-deduplication dashboard mart checks:

- `mart_station_status_latest_enriched`: 240 rows and 240 distinct stations
- `mart_station_risk_summary_enriched`: 240 rows and 240 distinct stations

## Data window and limitations

The project uses real GBFS São Paulo data collected during a short project window and then frozen for delivery. The dashboard and marts are suitable for demonstrating an end-to-end data engineering pipeline, but they should not be interpreted as a long-term operational study of São Paulo bike-sharing behavior.

Raw local data is intentionally excluded from git through `data/`. The reproducible delivery path is source ingestion, local raw landing, GCS upload, BigQuery raw load, dbt transformation, and Looker Studio visualization.

## Repository structure

```text
.
├── dashboard/
├── dbt/
│   └── bikeflow_sp/
├── docs/
├── flink/
│   ├── jobs/
│   └── sql/
├── infra/
│   └── terraform/
├── kestra/
│   └── flows/
├── producer/
│   ├── app/
│   ├── tests/
│   └── requirements.txt
├── scripts/
├── .env.example
├── .gitignore
├── docker-compose.yml
└── README.md
```
