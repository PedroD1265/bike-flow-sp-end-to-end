select
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
    date(ingested_at) as snapshot_date,
    extract(hour from ingested_at) as snapshot_hour
from {{ source('bikeflow_raw', 'station_information_raw') }}
qualify row_number() over (
    partition by station_id
    order by ingested_at desc
) = 1
