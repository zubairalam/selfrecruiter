
node "sr" {
	$user = "vagrant"

	Exec {
		path => [ "/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"],
		user => $user,
		timeout => 3600,
		tries => 10,
		#logoutput => true,
	}

	exec { "apt-update":
		command => "apt-get update",
		user => root
	}

	Exec["apt-update"] -> Package <| |>

	Group {
		ensure => present,
	}

	Package {
		ensure => "present"
	}

	Service {
		ensure  => "running",
		enable  => "true",
	}

	Cron {
		user    => root,
		hour    => "*",
		minute  => "*",
		month   => "*",
		monthday => "*",
		weekday => "*",
	}

  include core
  include system
  include elasticsearch
  # include memcached
  # include postgresql
  include mysql
  # include mongo
  include rabbitmq
  include redis
  include python
  include nodejs
  include nginx
  include supervisor
}



