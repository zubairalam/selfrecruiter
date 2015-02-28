class redis{
  $password = "vagrant"

  package { "redis-server": require => Class["rabbitmq"] }

  service { "redis-server": require => Package["redis-server"] }

  exec { 'auth-redis':
    notify  => Service["redis-server"],
    command => 'sed -i "s/^# requirepass foobared/requirepass vagrant/g" /etc/redis/redis.conf', # sed not allowing password here!
    user => root,
    require => Package["redis-server"]
  }
}

