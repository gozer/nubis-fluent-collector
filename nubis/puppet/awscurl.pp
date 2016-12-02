class { 'python':
    pip => true,
}

python::pip { 'awscurl':
    ensure => 'latest',
    url    => 'git+https://github.com/gozer/awscurl.git@c94d3fa07b8b30a9c0adb9ab92d94fda1edb5af9',
    require => [
      Package['git'],
      Python::Pip['botocore'],
      Python::Pip['urllib3[secure]'],
    ],
}

python::pip {'botocore':
  ensure => '1.4.67',
}

python::pip { 'urllib3[secure]':
  ensure => '1.19',
  require => [
    Package['libssl-dev'],
    Package['libffi-dev'],
  ],
}

package { "libssl-dev":
  ensure => '1.0.1f-1ubuntu2.21',
}

package { "libffi-dev":
  ensure => '3.1~rc1+r3.0.13-12ubuntu0.1',
}

package { "git":
  ensure => '1:1.9.1-1ubuntu0.3',
}
