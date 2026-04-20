# BikeFlow SP Dashboard

Looker Studio dashboard: [BikeFlow SP Dashboard](https://datastudio.google.com/reporting/fd0249c0-9e47-499c-b3a0-12f585107ab7)

## Purpose

This dashboard presents the final analytics layer of the BikeFlow SP project. It shows how bike availability, shortage risk, and station-level operational imbalance can be monitored from curated dbt marts built on top of BigQuery.

## Data sources

* `bikeflow_analytics.mart_network_status_timeseries`
* `bikeflow_analytics.mart_network_status_latest`
* `bikeflow_analytics.mart_station_status_latest_enriched`
* `bikeflow_analytics.mart_station_risk_summary_enriched`

## Final dashboard tiles

### 1. Bike shortage rate over time (12 PM – 8 PM)

**Source:** `mart_network_status_timeseries`
**Purpose:** show how shortage rate evolved during the captured delivery window
**Type:** temporal line chart

### 2. Top 10 stations by bike shortage risk

**Source:** `mart_station_risk_summary_enriched`
**Purpose:** highlight stations with the highest modeled shortage risk
**Type:** ranked bar chart

### 3. Station risk summary

**Source:** `mart_station_risk_summary_enriched`
**Purpose:** provide supporting station-level detail for interpretation
**Columns:** station, capacity, bike shortage rate, peak shortage hour, dock saturation rate
**Type:** summary table

## What it shows

* Network-level shortage behavior over time
* Station-level shortage risk ranking
* Supporting context to interpret which stations are most affected and when

## Data window

The dashboard uses real GBFS São Paulo data collected during a short project window and frozen for delivery. It demonstrates the pipeline and analytical workflow, not a complete historical study.

## Interpretation notes

* A higher **bike shortage rate** means a station spent a larger share of the observed window with very low bike availability.
* The **peak shortage hour** indicates the hour in which shortage pressure was strongest for that station.
* The dashboard is intended for pipeline demonstration and operational pattern exploration, not for definitive long-term forecasting.
