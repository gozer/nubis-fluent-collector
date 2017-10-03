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

upstart::job { 'awsproxy':
    description    => 'AWS ES Proxy',
    service_ensure => 'stopped',
    require        => [
      Staging::File['/usr/local/bin/awsproxy'],
    ],
    # Never give up
    respawn        => true,
    respawn_limit  => 'unlimited',
    start_on       => '(local-filesystems and net-device-up IFACE!=lo)',
    env            => {
      'SLEEP_TIME' => 1,
      'GOMAXPROCS' => 2,
    },
    script         => '
  if [ -r /etc/profile.d/proxy.sh ]; then
    . /etc/profile.d/proxy.sh
  fi

  
  exec /usr/local/bin/awsproxy -target $(consulate kv get fluent-collector/$(nubis-metadata NUBIS_ENVIRONMENT)/config/ElasticSearch/AWSEndpoint)
',
    post_stop      => '
goal=$(initctl status $UPSTART_JOB | awk \'{print $2}\' | cut -d \'/\' -f 1)
if [ $goal != "stop" ]; then
    echo "Backoff for $SLEEP_TIME seconds"
    sleep $SLEEP_TIME
    NEW_SLEEP_TIME=`expr 2 \* $SLEEP_TIME`
    if [ $NEW_SLEEP_TIME -ge 60 ]; then
        NEW_SLEEP_TIME=60
    fi
    initctl set-env SLEEP_TIME=$NEW_SLEEP_TIME
fi
',
}

file { '/etc/consul/svc-awsproxy.json':
  ensure => file,
  owner  => root,
  group  => root,
  mode   => '0644',
  source => 'puppet:///nubis/files/svc-awsproxy.json',
}
