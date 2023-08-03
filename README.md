
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Cassandra Commitlog Pending Tasks Incident
---

The Cassandra Commitlog Pending Tasks incident type refers to an issue with pending tasks in the commitlog for a Cassandra database instance. This can potentially cause data loss and other performance issues if not resolved promptly. The incident is typically triggered by monitoring tools that detect high levels of pending tasks in the commitlog. It requires immediate attention and action from the responsible team to investigate and resolve the underlying issue.

### Parameters
```shell
# Environment Variables

export KEYSPACE="PLACEHOLDER"

export TABLE="PLACEHOLDER"

export COMMITLOG_DIRECTORY="PLACEHOLDER"

export NEW_COMMITLOG_SIZE="PLACEHOLDER"

export INSTANCE_NAME="PLACEHOLDER"

export CASSANDRA_HOST="PLACEHOLDER"

export CASSANDRA_PORT="PLACEHOLDER"
```

## Debug

### 1. Check the status of the Cassandra service
```shell
systemctl status cassandra
```

### 2. Check the Cassandra logs for any errors or warnings
```shell
tail -n 100 /var/log/cassandra/system.log
```

### 3. Check the commitlog directory for any pending tasks
```shell
ls -l /var/lib/cassandra/commitlog | grep -i "pending_tasks"
```

### 4. Check the Cassandra metrics for commitlog-related values
```shell
nodetool tablestats ${KEYSPACE}.${TABLE} | grep -i "commitlog"

nodetool cfstats | grep -i "commitlog"
```

### 5. Check the disk usage and availability on the Cassandra nodes
```shell
df -h
```

### Misconfiguration of the Cassandra database settings or cluster topology, causing issues with commitlog processing and pending tasks accumulation.
```shell
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


```

## Repair

### Set variables
```shell
INSTANCE=${INSTANCE_NAME}

COMMITLOG_DIR=${COMMITLOG_DIRECTORY}

COMMITLOG_SIZE=${NEW_COMMITLOG_SIZE}
```

### Stop Cassandra service
```shell
sudo service cassandra stop
```

### Increase commitlog disk space
```shell
sudo truncate -s ${COMMITLOG_SIZE} ${COMMITLOG_DIR}/CommitLog-*
```

### Start Cassandra service
```shell
sudo service cassandra start
```

### Next Step
```shell
echo "Commitlog disk space increased to ${COMMITLOG_SIZE} for instance ${INSTANCE}."
```

### Restart the Cassandra instance to clear out the pending tasks and allow for a fresh start. This can be a quick fix but should not be relied upon as a long-term solution.
```shell


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


```