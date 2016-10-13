class { 'datadog_agent::integrations::fluentd' :
  monitor_agent_url     => 'http://localhost:24220/api/plugins.json',
}
