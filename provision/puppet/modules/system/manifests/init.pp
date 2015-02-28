class system {
  $packages = [
        "build-essential",
		"curl",
        "g++",
		"gcc",
		"git-core",
		"graphicsmagick",
		"imagemagick",
		"make",
        "openjdk-7-jre",
        "unzip",
        "tar",
		"vim",
		"wget"
  ]

	
    $libs = [
        "liblcms2-dev",
        "libffi-dev",
        "libfreetype6-dev",
        "libjpeg8-dev",
        "libopenjpeg-dev",
        "libtiff4-dev",
        "libwebp-dev",
        "libxml2-dev",
        "libxslt1-dev",
        "libyaml-dev",
        "tcl8.5-dev",
        "tk8.5-dev",
        "zlib1g-dev",        
        "libssl-dev"
    ]

	package { $packages: require => Class["core"] }

	package { $libs: require => Package[$packages]}

    package { "bash": ensure => latest }
}