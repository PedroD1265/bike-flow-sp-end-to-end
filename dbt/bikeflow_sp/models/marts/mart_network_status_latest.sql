{{ config(materialized='table') }}

with ranked as (
    select
        *,
        row_number() over (
            order by snapshot_date desc, snapshot_hour desc
        ) as rn
    from {{ ref('mart_network_status_hourly') }}
)

select
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
from ranked
where rn = 1
