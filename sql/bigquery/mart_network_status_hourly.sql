CREATE OR REPLACE TABLE `bikeflow-sp-dezoomcamp.bikeflow_analytics.mart_network_status_hourly` AS
SELECT
  snapshot_date,
  snapshot_hour,
  COUNT(*) AS station_count,
  AVG(avg_vehicles_available) AS avg_vehicles_available_per_station,
  AVG(avg_docks_available) AS avg_docks_available_per_station,
  AVG(avg_bikes_availability_ratio) AS avg_bikes_availability_ratio,
  AVG(avg_docks_availability_ratio) AS avg_docks_availability_ratio,
  SUM(had_bike_shortage) AS stations_with_bike_shortage,
  SUM(had_dock_saturation) AS stations_with_dock_saturation,
  SAFE_DIVIDE(SUM(had_bike_shortage), COUNT(*)) AS bike_shortage_rate,
  SAFE_DIVIDE(SUM(had_dock_saturation), COUNT(*)) AS dock_saturation_rate
FROM `bikeflow-sp-dezoomcamp.bikeflow_analytics.mart_station_status_hourly`
GROUP BY 1, 2;