FROM kestra/kestra:latest

USER root

RUN apt-get update && \
    apt-get install -y curl ca-certificates gnupg python3 python3-pip python3-venv && \
    mkdir -p /usr/share/keyrings && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/google-cloud.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/google-cloud.gpg] http://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && \
    apt-get install -y google-cloud-cli && \
    python3 -m pip install --no-cache-dir dbt-bigquery && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER kestra