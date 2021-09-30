#!/bin/sh

function getContent {
  URL=$1

  echo "GET: $URL"
  OUTPUT=`curl -s -S --fail -H "Content-Type: application/json" -X GET -k -u ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} "https://${ELASTIC_HOST}:${ELASTIC_PORT}/$URL"`
  RET=$?

  echo $OUTPUT
  return $RET
}

function putContent {
  URL=$1
  CONTENT=$2

  echo "PUT: $URL"
  OUTPUT=`curl -s -S --fail -H "Content-Type: application/json" -X PUT -k -u ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} "https://${ELASTIC_HOST}:${ELASTIC_PORT}/$URL" -d "$CONTENT"`
  RET=$?
  echo $OUTPUT

  if [ $RET -ne 0 ] ; then
    echo "PUT request failed"
    return 1
  else
    echo "Connection succeeded"
  fi

  echo $OUTPUT | grep "{\"acknowledged\":true}" > /dev/null 2>&1
  if [ $? -ne 0 ] ; then
    echo "acknowledgement not found"
    return 1
  else
    echo "configuration acknowledged"
    return 0
  fi
}

getContent "_ilm/policy/default-beats"
if [ $? -eq 22 ] ; then
  putContent "_ilm/policy/default-beats" '
  {
    "policy": {
      "phases": {
        "hot": {
          "min_age": "0ms",
          "actions": {
            "set_priority": {
              "priority": 100
            }
          }
        },
        "delete": {
          "min_age": "90d",
          "actions": {
            "delete": {
              "delete_searchable_snapshot": true
            }
          }
        }
      }
    }
  }'
  if [ $? -ne 0 ] ; then 
    echo "default-beats update failed"
    exit 1
  fi
fi

getContent "_ilm/policy/default-filebeat-netflow"
if [ $? -eq 22 ] ; then
  putContent "_ilm/policy/default-filebeat-netflow" '
  {
    "policy": {
      "phases": {
        "hot": {
          "min_age": "0ms",
          "actions": {
            "set_priority": {
              "priority": 100
            }
          }
        },
        "delete": {
          "min_age": "30d",
          "actions": {
            "delete": {
              "delete_searchable_snapshot": true
            }
          }
        }
      }
    }
  }'
  if [ $? -ne 0 ] ; then 
    echo "default-filebeat-netflow update failed"
    exit 1
  fi
fi

# getContent "_template/default-beats-map"
# if [ $? -eq 22 ] ; then
#   putContent "_template/default-beats-map?include_type_name" '
#   {
#     "order": -10,
#     "index_patterns": [
#       "auditbeat-*",
#       "filebeat-*",
#       "winlogbeat-*"
#     ],
#     "settings": {
#       "index": {
#         "lifecycle": {
#           "name": "default-beats"
#         }
#       }
#     },
#     "aliases": {},
#     "mappings": {}
#   }'
#   if [ $? -ne 0 ] ; then 
#     echo "default-beats-map update failed"
#     exit 1
#   fi
# fi

# getContent "_template/default-filebeat-netflow-map"
# if [ $? -eq 22 ] ; then
#   putContent "_template/default-filebeat-netflow-map?include_type_name" '
#   {
#     "order": -1,
#     "index_patterns": [
#       "filebeat-netflow-*"
#     ],
#     "settings": {
#       "index": {
#         "lifecycle": {
#           "name": "default-filebeat-netflow"
#         }
#       }
#     },
#     "aliases": {},
#     "mappings": {}
#   }'
#   if [ $? -ne 0 ] ; then 
#     echo "default-filebeat-netflow-map update failed"
#     exit 1
#   fi
# fi

exit 0
