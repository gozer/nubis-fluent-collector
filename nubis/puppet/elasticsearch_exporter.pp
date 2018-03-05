$elasticsearch_exporter_version = '1.0.2rc2'
$elasticsearch_exporter_url = "https://github.com/justwatchcom/elasticsearch_exporter/releases/download/v${elasticsearch_exporter_version}/elasticsearch_exporter-${elasticsearch_exporter_version}.linux-amd64.tar.gz"

notice ("Grabbing elasticsearch_exporter ${elasticsearch_exporter_version}")

staging::file { "elasticsearch_exporter-${elasticsearch_exporter_version}.tar.gz":
  source => $elasticsearch_exporter_url,
}
->staging::extract { "elasticsearch_exporter-${elasticsearch_exporter_version}.tar.gz":
  strip   => 1,
  target  => '/usr/local/bin',
  creates => '/usr/local/bin/elasticsearch_exporter',
}
->exec { 'fix elasticsearch_exporter permissions':
  command => 'chmod 755 /usr/local/bin/elasticsearch_exporter',
  path    => ['/sbin','/bin','/usr/sbin','/usr/bin','/usr/local/sbin','/usr/local/bin'],
}

# Gets triggered by awsproxy startup/shutdown
systemd::unit_file { 'elasticsearch_exporter.service':
  source => 'puppet:///nubis/files/elasticsearch_exporter.systemd',
}
