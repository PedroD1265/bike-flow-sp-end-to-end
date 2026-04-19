select
    station_id,
    snapshot_date,
    snapshot_hour,
    count(*) as snapshots_in_hour,
    avg(num_vehicles_available) as avg_vehicles_available,
    avg(num_docks_available) as avg_docks_available,
    avg(total_capacity) as avg_total_capacity,
    avg(bikes_availability_ratio) as avg_bikes_availability_ratio,
    avg(docks_availability_ratio) as avg_docks_availability_ratio,
    countif(is_bike_shortage) as bike_shortage_events,
    countif(is_dock_saturation) as dock_saturation_events,
    max(cast(is_bike_shortage as int64)) as had_bike_shortage,
    max(cast(is_dock_saturation as int64)) as had_dock_saturation
from {{ ref('stg_station_status') }}
group by 1, 2, 3
