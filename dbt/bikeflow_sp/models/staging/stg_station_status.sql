select
    station_id,
    num_vehicles_available,
    num_docks_available,
    last_reported,
    is_installed,
    is_renting,
    is_returning,
    ingested_at,
    date(ingested_at) as snapshot_date,
    extract(hour from ingested_at) as snapshot_hour,
    num_vehicles_available + num_docks_available as total_capacity,
    safe_divide(
        num_vehicles_available,
        num_vehicles_available + num_docks_available
    ) as bikes_availability_ratio,
    safe_divide(
        num_docks_available,
        num_vehicles_available + num_docks_available
    ) as docks_availability_ratio,
    case
        when num_vehicles_available = 0 then true
        else false
    end as is_bike_shortage,
    case
        when num_docks_available = 0 then true
        else false
    end as is_dock_saturation
from {{ source('bikeflow_raw', 'station_status_raw') }}
