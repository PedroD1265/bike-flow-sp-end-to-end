CREATE OR REPLACE TABLE `bikeflow-sp-dezoomcamp.bikeflow_analytics.mart_station_risk_summary` AS
SELECT
  station_id,
  COUNT(*) AS station_hour_observations,
  AVG(avg_vehicles_available) AS avg_vehicles_available,
  AVG(avg_docks_available) AS avg_docks_available,
  AVG(avg_bikes_availability_ratio) AS avg_bikes_availability_ratio,
  AVG(avg_docks_availability_ratio) AS avg_docks_availability_ratio,
  SUM(had_bike_shortage) AS bike_shortage_hours,
  SUM(had_dock_saturation) AS dock_saturation_hours,
  SAFE_DIVIDE(SUM(had_bike_shortage), COUNT(*)) AS bike_shortage_hour_rate,
  SAFE_DIVIDE(SUM(had_dock_saturation), COUNT(*)) AS dock_saturation_hour_rate
FROM `bikeflow-sp-dezoomcamp.bikeflow_analytics.mart_station_status_hourly`
GROUP BY 1;