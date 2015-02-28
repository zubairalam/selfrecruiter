class postgresql {
	$db_name = "db"
	$db_user = "vagrant"
	$db_pass = "vagrant123"
	$db_host = "localhost"

  $packages = [
    "libpq-dev",
    "postgresql",
    "postgresql-contrib"
  ]

	package { $packages: require => Class["memcached"] }
  service { "postgresql": require => Package[$packages]	}

	exec { "config-postgresql-locale":
		command => "sudo -u postgres psql -c \"UPDATE pg_database SET datistemplate=FALSE WHERE datname='template1';\" && \
		            sudo -u postgres psql -c \"DROP DATABASE template1;\" && \
		            sudo -u postgres psql -c \"CREATE DATABASE template1 WITH owner=postgres template=template0 encoding='UTF8';\" && \
		            sudo -u postgres psql -c \"UPDATE pg_database SET datistemplate=TRUE WHERE datname='template1';\"",
		require => Service["postgresql"],
	}

	exec { "config-postgresql-db":
		command => "sudo -u postgres createdb $db_name && \
		            sudo -u postgres createuser $db_user -s && \
		            sudo -u postgres psql -c \"alter user $db_user with encrypted password '$db_pass';\" && \
		            sudo -u postgres psql -c \"grant all privileges on database $db_name to $db_user;\"",
		require => Exec["config-postgresql-locale"],
	}
}
