# Helm Charts for Apache Kafka and Kafka Connect and other components

This repo contains Helm Charts Apache Kafka components

Add the repo:

```bash
helm repo add landoop https://landoop.github.io/kafka-helm-charts/
helm repo update
```

Regarding [stream-reactor](https://github.com/landoop/stream-reactor) and Kafka Connectors any environment variable beginning with ``CONNECT`` is used to build the Kafka Connect properties file, the Connect cluster is started with this file in distributed mode. Any
environment variable starting with ``CONNECTOR`` is used to make the Connector properties file, which is posted into
the Connect cluster to start the connector.

# Building/Testing

Run ``check.sh`` this in turn calls ``scripts/lint.sh`` which will perform linting checks on the charts and also check we aren't going to overwrite existing charts.

If all good, checkin, tag and push the ```docs`` folder. This charts are hosted on the github page.

# Contribute

Contributions are welcome for any Kafka Connector or any other component that is useful for building Data Streaming pipelines
