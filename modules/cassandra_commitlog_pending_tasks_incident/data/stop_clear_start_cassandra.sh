

#!/bin/bash



# Stop the Cassandra service

sudo systemctl stop cassandra



# Wait for the service to stop

while sudo systemctl is-active cassandra; do

    sleep 1

done



# Clear out the commitlog directory

sudo rm -rf ${COMMITLOG_DIRECTORY}/*



# Start the Cassandra service

sudo systemctl start cassandra