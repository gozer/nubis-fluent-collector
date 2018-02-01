include ::fluentd

fluentd::install_plugin { 'retag':
  ensure      => '0.1.0',
  plugin_name => 'fluent-plugin-retag',
  plugin_type => 'gem',
}

fluentd::install_plugin { 'prometheus':
  ensure      => '1.0.1',
  plugin_name => 'fluent-plugin-prometheus',
  plugin_type => 'gem',
}

fluentd::install_plugin { 's3':
  ensure      => '1.1.1',
  plugin_name => 'fluent-plugin-s3',
  plugin_type => 'gem',
}

# Install our custom forks for now
fluentd::install_plugin { 'specific_install':
  ensure      => '0.3.3',
  plugin_name => 'specific_install',
  plugin_type => 'gem',
}->
exec { 'install fluent-plugin-sqs':
  command => '/opt/td-agent/embedded/bin/fluent-gem specific_install https://github.com/gozer/fluent-plugin-sqs.git nubis',
}->
exec { 'install fluent-plugin-elb-log':
  command => '/opt/td-agent/embedded/bin/fluent-gem specific_install https://github.com/gozer/fluent-plugin-elb-log.git nubis',
}

# Disabled until upstream fixes
#fluentd::install_plugin { 'elb-log':
#  ensure      => '0.4.3',
#  plugin_name => 'fluent-plugin-elb-log',
#  plugin_type => 'gem',
#}

# Disabled until upstream fixes
#fluentd::install_plugin { 'sqs':
#  ensure      => '2.1.0',
#  plugin_name => 'fluent-plugin-sqs',
#  plugin_type => 'gem',
#}

fluentd::install_plugin { 'elasticsearch':
  ensure      => '2.5.0',
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
