from pyflink.table import EnvironmentSettings, TableEnvironment


def main() -> None:
    settings = EnvironmentSettings.in_streaming_mode()
    t_env = TableEnvironment.create(settings)

    t_env.get_config().set(
        "pipeline.jars",
        "file:///opt/flink/lib/flink-sql-connector-kafka-1.17.2.jar",
    )

    # Make row-format files appear sooner
    t_env.get_config().set("execution.checkpointing.interval", "10 s")

    t_env.execute_sql("""
        CREATE TEMPORARY TABLE station_status_kafka (
            feed_name STRING,
            ingested_at STRING,
            payload ROW<
                station_id STRING,
                num_vehicles_available INT,
                num_docks_available INT,
                last_reported STRING,
                is_installed BOOLEAN,
                is_renting BOOLEAN,
                is_returning BOOLEAN
            >
        ) WITH (
            'connector' = 'kafka',
            'topic' = 'station_status',
            'properties.bootstrap.servers' = 'redpanda:9092',
            'properties.group.id' = 'bikeflow-station-status-raw',
            'scan.startup.mode' = 'earliest-offset',
            'format' = 'json',
            'json.ignore-parse-errors' = 'true'
        )
    """)

    t_env.execute_sql("""
        CREATE TEMPORARY TABLE station_status_fs (
            station_id STRING,
            num_vehicles_available INT,
            num_docks_available INT,
            last_reported STRING,
            is_installed BOOLEAN,
            is_renting BOOLEAN,
            is_returning BOOLEAN,
            ingested_at STRING,
            snapshot_date STRING,
            snapshot_hour STRING
        )
        PARTITIONED BY (snapshot_date, snapshot_hour)
        WITH (
            'connector' = 'filesystem',
            'path' = 'file:///opt/flink/data/raw/station_status',
            'format' = 'json',
            'sink.rolling-policy.file-size' = '1MB',
            'sink.rolling-policy.rollover-interval' = '30 s',
            'sink.rolling-policy.check-interval' = '10 s'
        )
    """)

    t_env.execute_sql("""
        INSERT INTO station_status_fs
        SELECT
            payload.station_id,
            payload.num_vehicles_available,
            payload.num_docks_available,
            payload.last_reported,
            payload.is_installed,
            payload.is_renting,
            payload.is_returning,
            ingested_at,
            SUBSTRING(payload.last_reported, 1, 10) AS snapshot_date,
            SUBSTRING(payload.last_reported, 12, 2) AS snapshot_hour
        FROM station_status_kafka
    """)


if __name__ == "__main__":
    main()