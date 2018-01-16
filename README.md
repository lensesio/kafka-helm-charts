# Helm Charts for Kafka Connect and related components

This repo contains Helm Charts for Landoop Connectors.

Add the repo:

```bash
helm repo add landoop https://landoop.github.io/helm-charts/
helm repo update
```

Uses DataMountaineer/Landoop dockers. Any environment variable beginning with ``CONNECT`` is used to build
the Kafka Connect properties file, the Connect cluster is started with this file in distributed mode. Any
environment variable starting with ``CONNECTOR`` is used to make the Connector properties file, which is posted into
the Connect cluster to start the connector.

# Building/Testing

Run ``check.sh`` this in turn calls ``scripts/lint.sh`` which will perform linting checks on the charts and also check we aren't going to overwrite existing charts.

If all good, checkin, tag and push the ```docs`` folder. This charts are hosted on the github page.
