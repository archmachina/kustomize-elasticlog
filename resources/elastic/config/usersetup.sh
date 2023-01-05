#!/bin/bash

touch /usr/share/elasticsearch/config/users
touch /usr/share/elasticsearch/config/users_roles
/usr/share/elasticsearch/bin/elasticsearch-users useradd "$ELASTIC_LOCAL_USERNAME" -p "$ELASTIC_LOCAL_PASSWORD"
/usr/share/elasticsearch/bin/elasticsearch-users passwd "$ELASTIC_LOCAL_USERNAME" -p "$ELASTIC_LOCAL_PASSWORD" || exit 1
/usr/share/elasticsearch/bin/elasticsearch-users roles "$ELASTIC_LOCAL_USERNAME" -a superuser || exit 1
