$awsproxy_version = '0.1.0'
$awsproxy_url = "https://github.com/cllunsford/aws-signing-proxy/releases/download/${awsproxy_version}/aws-signing-proxy"

notice ("Grabbing awsproxy ${awsproxy_version}")

staging::file { '/usr/local/bin/awsproxy':
  source => $awsproxy_url,
  target => '/usr/local/bin/awsproxy',
}->
exec { 'chmod /usr/local/bin/awsproxy':
  command => 'chmod 755 /usr/local/bin/awsproxy',
  path    => ['/sbin','/bin','/usr/sbin','/usr/bin','/usr/local/sbin','/usr/local/bin'],
}

systemd::unit_file { 'aws-proxy.service':
  source => 'puppet:///nubis/files/aws-proxy.systemd',
}->
service { 'aws-proxy':
  enable => true,
}

file { '/etc/consul/svc-awsproxy.json':
  ensure => file,
  owner  => root,
  group  => root,
  mode   => '0644',
  source => 'puppet:///nubis/files/svc-awsproxy.json',
}
