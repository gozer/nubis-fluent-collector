class { 'python':
    pip => true,
}

# Grab from a fork to get AWS fix for ES 5.1
python::pip { 'elasticsearch-curator':
  ensure => '6340e0beefe15ba0d114d1d91c425999145f08bf',
  url    => 'git+https://github.com/Talend/curator.git',
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
    command => 'nubis-cron cleanup-es-indices /usr/local/bin/nubis-cleanup-es-indices',
    require => [
      File['/usr/local/bin/nubis-cleanup-es-indices'],
    ],
}
