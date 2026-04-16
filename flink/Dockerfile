FROM flink:1.17.2-scala_2.12-java11

USER root

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    python3 -m pip install --no-cache-dir apache-flink==1.17.2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*