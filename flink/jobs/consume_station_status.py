from pyflink.table import EnvironmentSettings, TableEnvironment


def main() -> None:
    settings = EnvironmentSettings.in_streaming_mode()
    t_env = TableEnvironment.create(settings)

    t_env.get_config().set(
        "pipeline.jars",
        "file:///opt/flink/lib/flink-sql-connector-kafka-1.17.2.jar",
    )

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
            'properties.group.id' = 'bikeflow-station-status-smoke-test',
            'scan.startup.mode' = 'earliest-offset',
            'format' = 'json',
            'json.ignore-parse-errors' = 'true'
        )
    """)

    t_env.execute_sql("""
        CREATE TEMPORARY TABLE print_sink (
            station_id STRING,
            num_vehicles_available INT,
            num_docks_available INT,
            last_reported STRING,
            is_installed BOOLEAN,
            is_renting BOOLEAN,
            is_returning BOOLEAN,
            ingested_at STRING
        ) WITH (
            'connector' = 'print'
        )
    """)

    statement_set = t_env.create_statement_set()
    statement_set.add_insert_sql("""
        INSERT INTO print_sink
        SELECT
            payload.station_id,
            payload.num_vehicles_available,
            payload.num_docks_available,
            payload.last_reported,
            payload.is_installed,
            payload.is_renting,
            payload.is_returning,
            ingested_at
        FROM station_status_kafka
    """)
    statement_set.execute()


if __name__ == "__main__":
    main()