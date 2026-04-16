# Bike Flow SP End-to-End

Streaming data engineering project for analyzing bike station availability in São Paulo using GBFS, Kafka/Redpanda, PyFlink, GCS, BigQuery, dbt, and Looker Studio.

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

GBFS São Paulo → Python Producer → Redpanda/Kafka → PyFlink → GCS → Kestra → BigQuery → dbt → Looker Studio

## Tech stack

- **Source:** GBFS São Paulo
- **Ingestion:** Python producer
- **Broker:** Redpanda / Kafka
- **Stream processing:** PyFlink
- **Data lake:** Google Cloud Storage
- **Data warehouse:** BigQuery
- **Transformations:** dbt
- **Dashboard:** Looker Studio
- **IaC:** Terraform

## Planned dashboard tiles

1. **Temporal view:** bike availability trend over time
2. **Categorical view:** stations or regions with the highest shortage/saturation rate

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