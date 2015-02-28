class python {
  # scope variables
  $virtualenv_name = "project" # virtual environment name
  $virtualenv_user = "vagrant" # vagrant user
  $virtualenv_home_path = "/home/$virtualenv_user" # home path of the vagrant user
  $virtualenv_path = "$virtualenv_home_path/.virtualenvs/$virtualenv_name" # path of the virtualenv.
  $python = "python" # version of python: either python or python3
  $requirements_file = "/$virtualenv_user/project/mpiq/requirements.txt"
  $packages = [
          $python, "$python-dev", "$python-docutils", "$python-pip",
          "$python-setuptools", "python-software-properties", "$python-tk", "$python-virtualenv",
          "virtualenvwrapper", "fabric"
  ]
    $pip_proxy_folder = '/$virtualenv_user/cache'

  # let's rock!
  package { $packages:
      require => Class["mysql"]
    }

  exec { "create-virtualenv-$virtualenv_name":
    command => "virtualenv $virtualenv_path",
    require => Package[$packages],
  }

  /*exec { "install-requirements-$virtualenv_name":
    command => "$virtualenv_path/bin/pip install -r $requirements_file",
    require => Exec["create-virtualenv-$virtualenv_name"],
  }*/
}