include ::fluentd

fluentd::install_plugin { 'elb':
  ensure      => '0.2.5',
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-elb-log',
}

fluentd::install_plugin { 's3':
  ensure      => '0.6.5',
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-s3',
}

fluentd::install_plugin { 'sqs':
  ensure      => '1.7.0',
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-sqs',
}

fluentd::install_plugin { 'aws-elasticsearch-service':
  ensure      => '0.1.4',
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-aws-elasticsearch-service',
}->wget::fetch { "patch aws-elasticsearch-service for ruby < 2":
    source => "https://raw.githubusercontent.com/atomita/fluent-plugin-aws-elasticsearch-service/a823433920bb183dbdda087f3c0fcca6c381bef7/lib/fluent/plugin/out_aws-elasticsearch-service.rb",
    destination => "/usr/lib/fluent/ruby/lib/ruby/gems/1.9.1/gems/fluent-plugin-aws-elasticsearch-service-0.1.4/lib/fluent/plugin/out_aws-elasticsearch-service.rb",
    user => "root",
    verbose => true,
    redownload => true, # The file already exists, we replace it
}->wget::fetch { "patch faraday_middleware-aws-signers for ruby < 2":
    source => "https://raw.githubusercontent.com/winebarrel/faraday_middleware-aws-signers-v4/20a3740db1b7ad1e0877b7c49dfe07c7d57c2c42/lib/faraday_middleware/aws_signers_v4_ext.rb",
    destination => "/usr/lib/fluent/ruby/lib/ruby/gems/1.9.1/gems/faraday_middleware-aws-signers-v4-0.1.1/lib/faraday_middleware/aws_signers_v4_ext.rb",
    user => "root",
    verbose => true,
    redownload => true, # The file already exists, we replace it
}

fluentd::install_plugin { 'elasticsearch':
  ensure      => '1.3.0',
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-elasticsearch',
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

