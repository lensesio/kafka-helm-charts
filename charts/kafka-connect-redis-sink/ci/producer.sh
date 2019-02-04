#!/bin/bash

POD=$(kubectl get pods --field-selector=status.phase=Running -l=app=test-kafka-connect-redis -o jsonpath='{.items[0].metadata.name}')

kubectl exec -i $POD -c kafka -- kafka-avro-console-producer --broker-list localhost:9092 --topic redis-sink --property value.schema='{"type":"record","name":"User","namespace":"com.datamountaineer.streamreactor.connect.redis","fields":[{"name":"firstName","type":"string"},{"name":"lastName","type":"string"},{"name":"age","type":"int"},{"name":"salary","type":"double"}]}'
