class { 'python':
    pip => true,
}

python::pip { 'elasticsearch-curator':
    ensure  => '3.5.1',
}

file { '/usr/local/bin/nubis-cleanup-es-indices':
  ensure  => file,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    Python::Pip['elasticsearch-curator'],
  ],
  source  => 'puppet:///nubis/files/nubis-cleanup-es-indices',
}

cron::daily { 'nubis-cleanup-es-indices':
    user    => 'root',
    command => '/usr/local/sbin/nubis-cleanup-es-indices',
    require => [
      File['/usr/local/bin/nubis-cleanup-es-indices'],
    ],
}
