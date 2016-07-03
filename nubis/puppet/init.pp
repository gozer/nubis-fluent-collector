include ::fluentd

package { "fluent-plugin-elb-log":
  ensure   => "0.2.6",
  provider => "fluentgem",
  source   => "http://people.mozilla.org/~pchiasson/ruby",
  require     => [
    Package["td-agent"],
  ],
}
package { "fluent-plugin-s3":
  ensure   => "0.6.8",
  provider => "fluentgem",
  source   => "http://people.mozilla.org/~pchiasson/ruby",
  require     => [
    Package["td-agent"],
  ],
}

fluentd::install_plugin { 'sqs':
  ensure      => '1.7.0',
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-sqs',
}

package { "fluent-plugin-aws-elasticsearch-service":
  ensure   => "0.1.6",
  provider => "fluentgem",
  source   => "http://people.mozilla.org/~pchiasson/ruby",
  require     => [
    Package["td-agent"],
  ],
}

package { "fluent-plugin-elasticsearch":
  ensure   => "1.5.0",
  provider => "fluentgem",
  source   => "http://people.mozilla.org/~pchiasson/ruby",
  require     => [
    Package["td-agent"],
  ],
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

file { "/etc/nubis.d/fluent":
  source => "puppet:///nubis/files/fluent-startup",
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
}
