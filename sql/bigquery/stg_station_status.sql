CREATE OR REPLACE VIEW `bikeflow-sp-dezoomcamp.bikeflow_analytics.stg_station_status` AS
SELECT
  station_id,
  num_vehicles_available,
  num_docks_available,
  last_reported,
  is_installed,
  is_renting,
  is_returning,
  ingested_at,
  DATE(ingested_at) AS snapshot_date,
  EXTRACT(HOUR FROM ingested_at) AS snapshot_hour,
  num_vehicles_available + num_docks_available AS total_capacity,
  SAFE_DIVIDE(num_vehicles_available, num_vehicles_available + num_docks_available) AS bikes_availability_ratio,
  SAFE_DIVIDE(num_docks_available, num_vehicles_available + num_docks_available) AS docks_availability_ratio,
  CASE WHEN num_vehicles_available = 0 THEN TRUE ELSE FALSE END AS is_bike_shortage,
  CASE WHEN num_docks_available = 0 THEN TRUE ELSE FALSE END AS is_dock_saturation
FROM `bikeflow-sp-dezoomcamp.bikeflow_raw.station_status_raw`;