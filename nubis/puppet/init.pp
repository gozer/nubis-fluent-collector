include ::fluentd

fluentd::install_plugin { 'elb':
  ensure      => '0.2.5',
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-elb-log',
}

fluentd::install_plugin { 's3':
  ensure      => '0.5.11',
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-s3',
}

fluentd::install_plugin { 'sqs':
  ensure      => '1.6.1',
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-sqs',
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

file { "/etc/confd":
  ensure  => directory,
  recurse => true,
  purge => false,
  owner => 'root',
  group => 'root',
  source => "puppet:///nubis/files/confd",
}
