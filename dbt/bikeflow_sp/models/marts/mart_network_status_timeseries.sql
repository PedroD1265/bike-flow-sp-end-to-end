{{ config(materialized='view') }}

select
    timestamp(datetime(snapshot_date, time(snapshot_hour, 0, 0))) as snapshot_ts,
    snapshot_date,
    snapshot_hour,
    station_count,
    avg_vehicles_available_per_station,
    avg_docks_available_per_station,
    avg_bikes_availability_ratio,
    avg_docks_availability_ratio,
    stations_with_bike_shortage,
    stations_with_dock_saturation,
    bike_shortage_rate,
    dock_saturation_rate
from {{ ref('mart_network_status_hourly') }}
