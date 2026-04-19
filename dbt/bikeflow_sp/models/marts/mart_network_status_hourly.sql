select
    snapshot_date,
    snapshot_hour,
    count(*) as station_count,
    avg(avg_vehicles_available) as avg_vehicles_available_per_station,
    avg(avg_docks_available) as avg_docks_available_per_station,
    avg(avg_bikes_availability_ratio) as avg_bikes_availability_ratio,
    avg(avg_docks_availability_ratio) as avg_docks_availability_ratio,
    sum(had_bike_shortage) as stations_with_bike_shortage,
    sum(had_dock_saturation) as stations_with_dock_saturation,
    safe_divide(sum(had_bike_shortage), count(*)) as bike_shortage_rate,
    safe_divide(sum(had_dock_saturation), count(*)) as dock_saturation_rate
from {{ ref('mart_station_status_hourly') }}
group by 1, 2
