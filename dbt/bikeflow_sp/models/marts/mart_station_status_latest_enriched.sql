{{ config(materialized='table') }}

with latest_snapshot as (
    select
        snapshot_date,
        snapshot_hour
    from {{ ref('mart_network_status_latest') }}
),

latest_station_status as (
    select s.*
    from {{ ref('mart_station_status_hourly_enriched') }} s
    inner join latest_snapshot l
        on s.snapshot_date = l.snapshot_date
       and s.snapshot_hour = l.snapshot_hour
)

select *
from latest_station_status
