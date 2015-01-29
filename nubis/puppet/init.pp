include ::fluentd

fluentd::configfile { 'collector': }

fluentd::source { 'forwarder':
  configfile => "collector",
  type => "forward",
}

fluentd::match { 'collector':
  configfile => "collector",
  pattern => '**',
  type  => 'file',
  config  => {
     'path' => "/var/log/fluent-all.log",
     'time_slice_format' => "%Y%m%d",
     'time_slice_wait'   =>  "10m",
     'time_format'       => "%Y%m%dT%H%M%S%z",
     'compress'          =>  "gzip",
  }   
}
