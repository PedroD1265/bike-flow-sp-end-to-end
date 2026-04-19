{{ config(materialized='view') }}

with station_5min as (
    select
        station_id,
        timestamp_seconds(300 * div(unix_seconds(ingested_at), 300)) as snapshot_5min,
        avg(num_vehicles_available) as avg_vehicles_available,
        avg(num_docks_available) as avg_docks_available,
        avg(total_capacity) as avg_total_capacity,
        avg(bikes_availability_ratio) as avg_bikes_availability_ratio,
        avg(docks_availability_ratio) as avg_docks_availability_ratio,
        max(cast(is_bike_shortage as int64)) as had_bike_shortage,
        max(cast(is_dock_saturation as int64)) as had_dock_saturation
    from {{ ref('stg_station_status') }}
    group by 1, 2
)

select
    snapshot_5min,
    date(snapshot_5min) as snapshot_date,
    extract(hour from snapshot_5min) as snapshot_hour,
    count(*) as station_count,
    avg(avg_vehicles_available) as avg_vehicles_available_per_station,
    avg(avg_docks_available) as avg_docks_available_per_station,
    avg(avg_bikes_availability_ratio) as avg_bikes_availability_ratio,
    avg(avg_docks_availability_ratio) as avg_docks_availability_ratio,
    sum(had_bike_shortage) as stations_with_bike_shortage,
    sum(had_dock_saturation) as stations_with_dock_saturation,
    safe_divide(sum(had_bike_shortage), count(*)) as bike_shortage_rate,
    safe_divide(sum(had_dock_saturation), count(*)) as dock_saturation_rate
from station_5min
group by 1, 2, 3
