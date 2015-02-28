class memcached {
  package { "memcached": require => Class["elasticsearch"] }
	service { "memcached": require => Package["memcached"] }
}

