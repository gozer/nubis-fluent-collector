include ::fluentd

fluentd::install_plugin { 'retag':
  ensure      => '0.0.2',
  plugin_name => 'fluent-plugin-retag',
  plugin_type => 'gem',
}

fluentd::install_plugin { 'prometheus':
  ensure      => '0.2.1',
  plugin_name => 'fluent-plugin-prometheus',
  plugin_type => 'gem',
}

fluentd::install_plugin { 'elb-log':
  ensure      => '0.2.7',
  plugin_name => 'fluent-plugin-elb-log',
  plugin_type => 'gem',
}

fluentd::install_plugin { 's3':
  ensure      => '0.7.2',
  plugin_name => 'fluent-plugin-s3',
  plugin_type => 'gem',
}

fluentd::install_plugin { 'sqs':
  ensure      => '1.7.1',
  plugin_name => 'fluent-plugin-sqs',
  plugin_type => 'gem',
}

fluentd::install_plugin { 'aws-elasticsearch-service':
  ensure      => '0.1.6',
  plugin_name => 'fluent-plugin-aws-elasticsearch-service',
  plugin_type => 'gem',
}

fluentd::install_plugin { 'elasticsearch':
  ensure      => '1.8.0',
  plugin_name => 'fluent-plugin-elasticsearch',
  plugin_type => 'gem',
}

file { '/var/log/fluentd':
  ensure => 'directory',
  owner  => 'td-agent',
  group  => 'td-agent',
  mode   => '0750',
}

# XXX: This needs its own managed module, consul::service doesn't quite work here either ;-(
file { '/etc/consul/svc-fluentd-collector.json':
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => '{"service":{"check":{"interval":"10s","script":"/usr/bin/curl -s http://localhost:24220/api/plugins.json"},"port":24224,"tags":["collector","production"],"name":"fluentd"}}'
}

file { '/etc/confd':
  ensure  => directory,
  recurse => true,
  purge   => false,
  owner   => 'root',
  group   => 'root',
  source  => 'puppet:///nubis/files/confd',
}

file { '/etc/nubis.d/fluent':
  source => 'puppet:///nubis/files/fluent-startup',
  owner  => 'root',
  group  => 'root',
  mode   => '0755',
}

file { '/etc/td-agent/elasticsearch-logstash-template.json':
  source  => 'puppet:///nubis/files/elasticsearch-logstash-template.json',
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  require => [
    Class['Fluentd'],
  ],
}
