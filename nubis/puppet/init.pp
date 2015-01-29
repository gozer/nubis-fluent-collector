include ::fluentd

fluentd::source { 'forwarder':
  configfile => "forwarder",
  type => "forward",
}

fluentd::match { 'collector':
  configfile => "collect-to-disk",
  pattern => '**',
  type  => 'file',
  config  => {
     'path' => "/var/log/fluent-all.log",
     'time_slice_format' => "%Y%m%d",
     'time_slice_wait'   =>  "10m",
     'time_format'       => "%Y%m%dT%H%M%S%z",
     'compress'          =>  "gzip",
  },
}

# all rsyslog daemons on the clients sends their messages to 5140
fluentd::source { 'rsyslog':
  configfile => "syslog",
  type   => 'syslog',
  config => {
    'port' => '5140',
    'bind' => '0.0.0.0',
    'tag'  => 'system.local',
  },
}
