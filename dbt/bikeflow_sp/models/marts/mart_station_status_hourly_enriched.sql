select
    m.station_id,
    s.station_name,
    s.short_name,
    s.lat,
    s.lon,
    s.address,
    s.capacity,
    s.is_charging_station,
    s.is_virtual_station,
    m.snapshot_date,
    m.snapshot_hour,
    m.snapshots_in_hour,
    m.avg_vehicles_available,
    m.avg_docks_available,
    m.avg_total_capacity,
    m.avg_bikes_availability_ratio,
    m.avg_docks_availability_ratio,
    m.bike_shortage_events,
    m.dock_saturation_events,
    m.had_bike_shortage,
    m.had_dock_saturation
from {{ ref('mart_station_status_hourly') }} m
left join {{ ref('stg_station_information') }} s
    using (station_id)
