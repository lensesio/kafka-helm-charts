#!/bin/bash

timeout 20
POD=$(kubectl get pods --field-selector=status.phase=Running -l=app=test-kafka-connect-elastic -o jsonpath='{.items[0].metadata.name}')

kubectl exec -i $POD -c kafka -- kafka-avro-console-producer --broker-list localhost:9092 --topic elastic-sink --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"id","type":"int"},{"name":"random_field","type":"string"}]}'
