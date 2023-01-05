#!/bin/sh

attempt=0
wait=30
while [ $attempt -lt 20 ] ; do
  echo "Attempt: $attempt"
  curl --fail -H "Content-Type: application/json" -v -k -u ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} -X GET https://${ELASTIC_HOST}:${ELASTIC_PORT}/_cat/health &&
  curl --fail -H "Content-Type: application/json" -v -k -u ${KIBANA_USERNAME}:${KIBANA_PASSWORD} -X GET https://${KIBANA_HOST}:${KIBANA_PORT}/api/features &&
  exit 0

  echo "Test failed. Sleeping"
  sleep $wait
  attempt=`expr $attempt + 1`
done

echo "Exhausted attempts - exiting"
exit 1
