include ::fluentd

fluentd::install_plugin { 's3':
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-s3',
}

fluentd::configfile { 'collector': }

fluentd::source { 'forwarder':
  configfile => "collector",
  type => "forward",
}

fluentd::source { 'monitor':
  configfile => "collector",
  type => "monitor_agent",
  config  => {
    'port' => "24220"
  }
}

file { "/var/log/fluentd":
  ensure => "directory",
  owner  => "td-agent",
  group  => "td-agent",
  mode   => 750,
}

# XXX: This needs its own managed module, consul::service doesn't quite work here either ;-(
file { "/etc/consul/svc-fluentd-collector.json":
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => '{"service":{"check":{"interval":"10s","script":"/usr/bin/curl -s http://localhost:24220/api/plugins.json"},"port":24224,"tags":["collector","production"],"name":"fluentd"}}'
}

fluentd::match { 'collector':
  configfile => "collector",
  type => 's3',
  pattern => 'ec2.forward.**',

  config  => {
      'type'        => 's3',
      's3_bucket'   => '%%FLUENTD_S3_BUCKET%%',
      's3_region'   => '%%FLUENTD_S3_REGION%%',
      'buffer_path' => "/var/log/fluentd/s3.log",
      'check_apikey_on_start' => false,
      'time_slice_format' => '%Y%m%d%H%M',
      'utc'         => true,
  },
  require => File["/var/log/fluentd"]
}

# Fixes up the settings %%'ed above, not runtime-controlled, static for the lifetime of the stack
file { "/etc/nubis.d/fluentd-s3-config":
    owner => 'root',
    group => 'root',
    mode  => '0755',
    source => "puppet:///nubis/files/fluentd-fixups",
}
