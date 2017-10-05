$elasticsearch_exporter_version = '1.0.1'
$elasticsearch_exporter_url = "https://github.com/justwatchcom/elasticsearch_exporter/releases/download/v${elasticsearch_exporter_version}/elasticsearch_exporter-${elasticsearch_exporter_version}.linux-amd64.tar.gz"

notice ("Grabbing elasticsearch_exporter ${elasticsearch_exporter_version}")

staging::file { "elasticsearch_exporter-${elasticsearch_exporter_version}.tar.gz":
  source => $elasticsearch_exporter_url,
}->
staging::extract { "elasticsearch_exporter-${elasticsearch_exporter_version}.tar.gz":
  strip   => 1,
  target  => '/usr/local/bin',
  creates => '/usr/local/bin/elasticsearch_exporter',
}->
exec { 'fix elasticsearch_exporter permissions':
  command => 'chmod 755 /usr/local/bin/elasticsearch_exporter',
  path    => ['/sbin','/bin','/usr/sbin','/usr/bin','/usr/local/sbin','/usr/local/bin'],
}

upstart::job { 'elasticsearch_exporter':
    description    => 'ES Exporter',
    service_ensure => 'stopped',
    # Never give up
    respawn        => true,
    respawn_limit  => 'unlimited',
    start_on       => 'started awsproxy',
    stop_on        => 'stopped awsproxy',
    env            => {
      'SLEEP_TIME' => 1,
      'GOMAXPROCS' => 2,
    },
    script         => '
  if [ -r /etc/profile.d/proxy.sh ]; then
    . /etc/profile.d/proxy.sh
  fi

  
  exec /usr/local/bin/elasticsearch_exporter -es.all=true -web.listen-address=:9105 -es.uri="http://localhost:8080"
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
