# Helm Charts for Kafka Connect and related components

This repo contains Helm Charts for Landoop Connectors.

Add the repo:

```bash
helm repo add landoop https://landoop.github.io/helm-charts/
helm repo update
```

DataMountaineer dockers, base of Confluents. Any enviroment variable begining with ``CONNECT`` is used to build
the Kafka Connect properties file, the Connect cluster is started with this file in distributed mode. Any 
enviroment variable starting with ``CONNECTOR`` is used to make the Connector propertie file, which is posted into 
the Connect cluster to start the connector.
