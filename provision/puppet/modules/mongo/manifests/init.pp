class mongo {
  $db_name = "datawarehouse_db"
  $db_user = "vagrant"
  $db_pass = "vagrant"

  exec { "add-mongo-repo":
    command => "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
     echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list && \
     apt-get update",
    require => Class["nginx"]
  }

  package { "mongodb-org": require => Exec["add-mongo-repo"] }

  service { "mongod": require => Package["mongodb-org"] }

  exec { "create-mongo-db":
    command => "mongo $db_name --eval 'db.createUser({user:\"$db_user\", pwd:\"$db_pass\", roles: [ \"readWrite\", \"dbAdmin\" ]});'",
    require  => Package["mongodb-org"]
  }

  exec { "mongo-bind":
    command => "sed -i 's/bind_ip = 127.0.0.1/#bind_ip = 127.0.0.1/' /etc/mongod.conf",
    require => Exec["create-mongo-db"],
    notify => Service["mongod"]
  }

}
