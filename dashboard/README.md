# BikeFlow SP Dashboard

Looker Studio dashboard: TODO: add public Looker Studio URL

## Data sources

- `bikeflow_analytics.mart_network_status_timeseries`
- `bikeflow_analytics.mart_network_status_latest`
- `bikeflow_analytics.mart_station_status_latest_enriched`
- `bikeflow_analytics.mart_station_risk_summary_enriched`

## What it shows

- Network-level bike and dock availability over time.
- Latest station-level availability for the frozen delivery window.
- Stations with higher bike-shortage and dock-saturation rates.

## Data window

The dashboard uses real GBFS São Paulo data collected during a short project window and frozen for delivery. It demonstrates the pipeline and analytical workflow, not a complete historical study.
