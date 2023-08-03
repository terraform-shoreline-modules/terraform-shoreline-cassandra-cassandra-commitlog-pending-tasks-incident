resource "shoreline_notebook" "cassandra_commitlog_pending_tasks_incident" {
  name       = "cassandra_commitlog_pending_tasks_incident"
  data       = file("${path.module}/data/cassandra_commitlog_pending_tasks_incident.json")
  depends_on = [shoreline_action.invoke_commitlog_stats,shoreline_action.invoke_cassandra_monitor,shoreline_action.invoke_rename_script,shoreline_action.invoke_stop_clear_start_cassandra]
}

resource "shoreline_file" "commitlog_stats" {
  name             = "commitlog_stats"
  input_file       = "${path.module}/data/commitlog_stats.sh"
  md5              = filemd5("${path.module}/data/commitlog_stats.sh")
  description      = "4. Check the Cassandra metrics for commitlog-related values"
  destination_path = "/agent/scripts/commitlog_stats.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "cassandra_monitor" {
  name             = "cassandra_monitor"
  input_file       = "${path.module}/data/cassandra_monitor.sh"
  md5              = filemd5("${path.module}/data/cassandra_monitor.sh")
  description      = "Misconfiguration of the Cassandra database settings or cluster topology, causing issues with commitlog processing and pending tasks accumulation."
  destination_path = "/agent/scripts/cassandra_monitor.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "rename_script" {
  name             = "rename_script"
  input_file       = "${path.module}/data/rename_script.sh"
  md5              = filemd5("${path.module}/data/rename_script.sh")
  description      = "Set variables"
  destination_path = "/agent/scripts/rename_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "stop_clear_start_cassandra" {
  name             = "stop_clear_start_cassandra"
  input_file       = "${path.module}/data/stop_clear_start_cassandra.sh"
  md5              = filemd5("${path.module}/data/stop_clear_start_cassandra.sh")
  description      = "Restart the Cassandra instance to clear out the pending tasks and allow for a fresh start. This can be a quick fix but should not be relied upon as a long-term solution."
  destination_path = "/agent/scripts/stop_clear_start_cassandra.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_commitlog_stats" {
  name        = "invoke_commitlog_stats"
  description = "4. Check the Cassandra metrics for commitlog-related values"
  command     = "`chmod +x /agent/scripts/commitlog_stats.sh && /agent/scripts/commitlog_stats.sh`"
  params      = ["TABLE","KEYSPACE"]
  file_deps   = ["commitlog_stats"]
  enabled     = true
  depends_on  = [shoreline_file.commitlog_stats]
}

resource "shoreline_action" "invoke_cassandra_monitor" {
  name        = "invoke_cassandra_monitor"
  description = "Misconfiguration of the Cassandra database settings or cluster topology, causing issues with commitlog processing and pending tasks accumulation."
  command     = "`chmod +x /agent/scripts/cassandra_monitor.sh && /agent/scripts/cassandra_monitor.sh`"
  params      = ["CASSANDRA_PORT","CASSANDRA_HOST"]
  file_deps   = ["cassandra_monitor"]
  enabled     = true
  depends_on  = [shoreline_file.cassandra_monitor]
}

resource "shoreline_action" "invoke_rename_script" {
  name        = "invoke_rename_script"
  description = "Set variables"
  command     = "`chmod +x /agent/scripts/rename_script.sh && /agent/scripts/rename_script.sh`"
  params      = ["NEW_COMMITLOG_SIZE","COMMITLOG_DIRECTORY","INSTANCE_NAME"]
  file_deps   = ["rename_script"]
  enabled     = true
  depends_on  = [shoreline_file.rename_script]
}

resource "shoreline_action" "invoke_stop_clear_start_cassandra" {
  name        = "invoke_stop_clear_start_cassandra"
  description = "Restart the Cassandra instance to clear out the pending tasks and allow for a fresh start. This can be a quick fix but should not be relied upon as a long-term solution."
  command     = "`chmod +x /agent/scripts/stop_clear_start_cassandra.sh && /agent/scripts/stop_clear_start_cassandra.sh`"
  params      = ["COMMITLOG_DIRECTORY"]
  file_deps   = ["stop_clear_start_cassandra"]
  enabled     = true
  depends_on  = [shoreline_file.stop_clear_start_cassandra]
}

