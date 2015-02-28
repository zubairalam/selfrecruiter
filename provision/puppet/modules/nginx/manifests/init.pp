#https://uwsgi-docs.readthedocs.org/en/latest/tutorials/Django_and_nginx.html
#cut -d: -f1 /etc/group | sort

class nginx {
    $vagrant_user = "vagrant"
    $nginx_user = "www-data"

    package { "nginx": require => Class["nodejs"] }


    group { "www-data":
        require => Package["nginx"]
    }

    exec {"add-nginx-user":
        command => "sudo /usr/sbin/usermod -a -G $nginx_user $vagrant_user",
        require => Group["www-data"],
    }

    service { "nginx": require => Exec["add-nginx-user"] }

    file { "/etc/nginx/sites-enabled/default":
        ensure => "absent",
        require => Exec["add-nginx-user"]
    }

    file { "/etc/nginx/nginx.conf":
        source  => "puppet:///modules/nginx/nginx.conf",
        replace => true,
        require => File["/etc/nginx/sites-enabled/default"]
    }

    file { "/etc/nginx/sites-available/project_nginx.conf":
        ensure => "link",
        source => "puppet:///modules/nginx/project_nginx.conf",
        require => File["/etc/nginx/nginx.conf"]
    }

    file { "/etc/nginx/sites-enabled/project_nginx.conf":
        ensure => "link",
        notify  => Service["nginx"],
        source =>  "/etc/nginx/sites-available/project_nginx.conf",
        require => File["/etc/nginx/sites-available/project_nginx.conf"]
    }

}

