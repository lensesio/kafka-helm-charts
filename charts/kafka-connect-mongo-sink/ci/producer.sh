#!/bin/bash

POD=$(kubectl get pods --field-selector=status.phase=Running -l=app=test-kafka-connect-mongo -o jsonpath='{.items[0].metadata.name}')

kubectl exec -i $POD -c kafka -- kafka-avro-console-producer --broker-list localhost:9092 --topic mongo-sink --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"id","type":"int"},{"name":"created", "type": "string"}, {"name":"product", "type": "string"}, {"name":"price", "type": "double"}]}'