bash

#!/bin/bash



# Set the Cassandra instance host and port

HOST=${CASSANDRA_HOST}

PORT=${CASSANDRA_PORT}



# Check if Cassandra is running

if ! nc -z $HOST $PORT; then

  echo "Cassandra is not running"

  exit 1

fi



# Check the Cassandra cluster topology

if ! nodetool status | grep -q "UN"; then

  echo "Cassandra cluster is not healthy"

  exit 1

fi



# Check the Cassandra configuration settings

if ! grep -q "commitlog_total_space_in_mb" /etc/cassandra/cassandra.yaml; then

  echo "commitlog_total_space_in_mb setting is missing"

  exit 1

fi



# Check the current commitlog status

if ! nodetool cfstats | grep -q "Pending Tasks"; then

  echo "No pending tasks in the commitlog"

  exit 0

else

  echo "Pending tasks in the commitlog"

  exit 1

fi