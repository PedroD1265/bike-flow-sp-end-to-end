select
    r.station_id,
    s.station_name,
    s.short_name,
    s.address,
    s.capacity,
    s.lat,
    s.lon,
    s.is_charging_station,
    s.is_virtual_station,
    r.station_hour_observations,
    r.avg_vehicles_available,
    r.avg_docks_available,
    r.avg_bikes_availability_ratio,
    r.avg_docks_availability_ratio,
    r.bike_shortage_hours,
    r.dock_saturation_hours,
    r.bike_shortage_hour_rate,
    r.dock_saturation_hour_rate
from {{ ref('mart_station_risk_summary') }} r
left join {{ ref('stg_station_information') }} s
    using (station_id)
