class supervisor {
	$vagrant_user = "vagrant"
	$supervisor_user = "supervisor"

	package { "supervisor":	require => Class["python"]	}

	group { "supervisor": require => Package["supervisor"] }

  service { "supervisor":  require => Package["supervisor"] }

	exec {"add-supervisor-user":
		command => "sudo /usr/sbin/usermod -a -G $supervisor_user $vagrant_user",
		require => Group["supervisor"],
	}

	exec { "fix-supervisord-port":
		command => "sudo unlink /var/run/supervisor.sock", # sometimes may require: sudo unlink /tmp/supervisor.sock
		require => Exec["add-supervisor-user"],
	}

	file { "/etc/supervisor/supervisord.conf":
		ensure  => present,
		owner  => root,
		group  => root,
		mode   => "0755",
		source  => "puppet:///modules/supervisor/supervisord.conf",
		replace => true,
		require => Exec["fix-supervisord-port"],
	}

	exec {"enable-browser-integration":
		command => "sudo supervisord -c /etc/supervisor/supervisord.conf",
		require => File["/etc/supervisor/supervisord.conf"],
	}

	file { "/var/log/supervisor/celeryd.log":
	  	ensure => present,
	  	content => "",
		  require => Exec["enable-browser-integration"]
	}

	file { "/var/log/supervisor/celeryd_err.log":
	  	ensure => present,
	  	content => "",
		  require => Exec["enable-browser-integration"]
	}

  file { "/etc/supervisor/conf.d/celeryd.conf":
    notify  => Service["supervisor"],  # this sets up the relationship
		ensure  => present,
		owner  => root,
		group  => root,
		mode   => "0755",
		source  => "puppet:///modules/supervisor/celeryd.conf",
		replace => true,
		require => [File["/var/log/supervisor/celeryd_err.log"], File["/var/log/supervisor/celeryd.log"]]
	}

}