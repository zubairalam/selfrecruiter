class nodejs {
  $path = "/vagrant/mpiq/client/"
  $node_modules_path = "$path/node_modules/.bin"

  exec { "add-node-repo":
    command => "curl -sL https://deb.nodesource.com/setup | sudo bash -",
    require => Class["python"]
  }

  package { "nodejs": require => Exec["add-node-repo"] }

  exec { "upgrade-npm":
    command => "/usr/bin/npm update npm -g",
    user => root,
	  require => Package["nodejs"]
	}

  exec { "update-bashrc-default-npm":
    command => "/bin/echo 'export PATH=$node_modules_path:\$PATH' >> /home/vagrant/.bashrc",
	  require => Exec["upgrade-npm"]
	}

}
