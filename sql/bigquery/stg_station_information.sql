CREATE OR REPLACE VIEW `bikeflow-sp-dezoomcamp.bikeflow_analytics.stg_station_information` AS
SELECT
  station_id,
  external_id,
  station_name,
  short_name,
  lat,
  lon,
  address,
  capacity,
  is_charging_station,
  is_virtual_station,
  ingested_at,
  DATE(ingested_at) AS snapshot_date,
  EXTRACT(HOUR FROM ingested_at) AS snapshot_hour
FROM `bikeflow-sp-dezoomcamp.bikeflow_raw.station_information_raw`;