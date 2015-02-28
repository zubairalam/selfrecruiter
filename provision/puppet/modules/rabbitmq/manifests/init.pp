class rabbitmq {
  package { "rabbitmq-server": require => Class["mysql"] }

	service { "rabbitmq-server": require => Package["rabbitmq-server"] }
}

