resource "datadog_monitor" "connectiondifference"
{
	name = "902TF Connection difference more than 10% on gms server"
	type = "query alert"
	query = "avg(last_5m):abs( ( ( avg:sfs.connection_count{host:bingo-gms-${var.server1}} - avg:sfs.connection_count{host:bingo-gms-${var.server2}} ) / avg:sfs.connection_count{host:bingo-gms-${var.server1}} ) * 100 ) > 20"
	message = "Connection Difference between active SFS servers \n @pagerduty @slack-datadog @bingobash-devops@gsngames.com @pkumar@gsngames.com"
	tags = []
	notify_audit = "false"
	locked = "false"
	timeout_h = "0"
	silenced = {
		"*" = "${var.test1}"
	}
	include_tags = "false"
	no_data_timeframe = "300"
	require_full_window = "true"
	new_host_delay = "300"
	notify_no_data = "true"
	renotify_interval = "30"
	escalation_message = ""
	thresholds = {
		critical = "20"
		warning = "10"
	}
}

resource "datadog_monitor" "sfsconnectionmonitor"
{
  name = "601TF SFS connections."
  type = "metric alert"
  query = "avg(last_5m):avg:sfs.connection_count{!host:bingo-gms-${var.server3},!host:bingo-gms-${var.server4},!host:bingo-gms-${var.server5}} by {host} < 1200"
  message =  "Check SFS connection.\nHost name: {{host.name}} \nHost IP: {{host.ip}} \n\nEscalate and follow ,\nSFS restart process( according to runbook )after confirmation \n\nGroup {{host.group}} @pagerduty @slack-datadog @bingobash-devops@gsngames.com @pkumar@gsngames.com"
  tags = ["*"]
  notify_audit = "false"
  locked = "false"
  silenced = {
                "*" = "${var.test1}"
        } 
  timeout_h = "0"
  new_host_delay = "300"
  require_full_window = "true"
  notify_no_data = "true"
  renotify_interval = "30"
  escalation_message = ""
  no_data_timeframe = "300"
  include_tags = "true"
  thresholds = {
	critical = "1200"
	warning = "1300"
	}
}
