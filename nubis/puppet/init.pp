include ::fluentd

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
  content => '{"service":{"check":{"interval":"10s","script":"/usr/bin/curl http://localhost:24220/api/plugins.json"},"port":24224,"tags":["collector","production"],"name":"fluentd"}}'
}

fluentd::match { 'collector':
  configfile => "collector",
  pattern => 'forward.**',
  type  => 'file',
  config  => {
     'path' => "/var/log/fluentd/all.log",
     'time_slice_format' => "%Y%m%d",
     'time_slice_wait'   =>  "30m",
     'time_format'       => "%Y%m%dT%H%M%S%z",
     'compress'          =>  "gzip",
  },
  require => File["/var/log/fluentd"]
}
