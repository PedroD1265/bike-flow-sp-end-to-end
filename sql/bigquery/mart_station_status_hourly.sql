CREATE OR REPLACE TABLE `bikeflow-sp-dezoomcamp.bikeflow_analytics.mart_station_status_hourly` AS
SELECT
  station_id,
  snapshot_date,
  snapshot_hour,
  COUNT(*) AS snapshots_in_hour,
  AVG(num_vehicles_available) AS avg_vehicles_available,
  AVG(num_docks_available) AS avg_docks_available,
  AVG(total_capacity) AS avg_total_capacity,
  AVG(bikes_availability_ratio) AS avg_bikes_availability_ratio,
  AVG(docks_availability_ratio) AS avg_docks_availability_ratio,
  COUNTIF(is_bike_shortage) AS bike_shortage_events,
  COUNTIF(is_dock_saturation) AS dock_saturation_events,
  MAX(CAST(is_bike_shortage AS INT64)) AS had_bike_shortage,
  MAX(CAST(is_dock_saturation AS INT64)) AS had_dock_saturation
FROM `bikeflow-sp-dezoomcamp.bikeflow_analytics.stg_station_status`
GROUP BY 1, 2, 3;