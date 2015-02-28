class core {
	$timezone = 'Europe/London'

	exec { "set-swapon":
		command => "dd if=/dev/zero of=/swap bs=1M count=1024 && mkswap /swap && swapon /swap",
		user => root
	}
	exec { "set-locale":
  	command => "locale-gen en_GB.UTF-8",
  	user => root,
  	require => Exec["set-swapon"]
	}

	exec { "update-clock":
  	command => "ntpdate ntp.ubuntu.com",
  	user => root,
  	require => Exec["set-locale"]
	}

	exec { "set-tzdata":
		command => "echo $timezone  > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata",
		user => root,
		require => Exec["update-clock"]
	}

	exec { "set-user-bash":
	  command => "echo 'cd /vagrant/' >> /home/vagrant/.bashrc",
	  require => Exec["set-tzdata"]
	}

}