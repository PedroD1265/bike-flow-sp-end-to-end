select
    station_id,
    count(*) as station_hour_observations,
    avg(avg_vehicles_available) as avg_vehicles_available,
    avg(avg_docks_available) as avg_docks_available,
    avg(avg_bikes_availability_ratio) as avg_bikes_availability_ratio,
    avg(avg_docks_availability_ratio) as avg_docks_availability_ratio,
    sum(had_bike_shortage) as bike_shortage_hours,
    sum(had_dock_saturation) as dock_saturation_hours,
    safe_divide(sum(had_bike_shortage), count(*)) as bike_shortage_hour_rate,
    safe_divide(sum(had_dock_saturation), count(*)) as dock_saturation_hour_rate
from {{ ref('mart_station_status_hourly') }}
group by 1
