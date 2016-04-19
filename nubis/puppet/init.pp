include ::fluentd

$elb_log_version = '0.2.5'

fluentd::install_plugin { 'elb':
  ensure      => $elb_log_version,
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-elb-log',
}->
patch::file { "/usr/lib/fluent/ruby/lib/ruby/gems/1.9.1/gems/fluent-plugin-elb-log-$elb_log_version/lib/fluent/plugin/in_elb_log.rb":
  diff_content => "
diff --git a/lib/fluent/plugin/in_elb_log.rb b/lib/fluent/plugin/in_elb_log.rb
index b248709..f18a942 100644
--- a/in_elb_log.rb
+++ b/in_elb_log.rb
@@ -18,7 +18,7 @@ class Fluent::Elb_LogInput < Fluent::Input
   config_param :timestamp_file, :string, :default => nil
   config_param :refresh_interval, :integer, :default => 300
   config_param :buf_file, :string, :default => './fluentd_elb_log_buf_file'
-  config_param :proxy_uri, :string, :default => nil
+  config_param :http_proxy, :string, :default => nil

   def configure(conf)
     super
"
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

file { "/etc/nubis.d/fluent":
  source => "puppet:///nubis/files/fluent-startup",
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
}
