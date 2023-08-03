nodetool tablestats ${KEYSPACE}.${TABLE} | grep -i "commitlog"

nodetool cfstats | grep -i "commitlog"