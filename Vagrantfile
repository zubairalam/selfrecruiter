VM_MEMORY = "1024"
VM_NAME = "sr"

Vagrant.require_version ">=1.6.0"
Vagrant.configure("2") do |config|
    config.vm.hostname = VM_NAME
    config.vm.synced_folder "project/", "/vagrant/project"
    config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct:true # nginx
    config.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct:true # nodejs client server
    config.vm.network :forwarded_port, guest: 4000, host: 4000, auto_correct:true # nodejs api server
    config.vm.network :forwarded_port, guest: 5432, host: 5432, auto_correct:true # postgres
    config.vm.network :forwarded_port, guest: 6379, host: 6379, auto_correct:true # redis
    config.vm.network :forwarded_port, guest: 8000, host: 8000, auto_correct:true # django
    config.vm.network :forwarded_port, guest: 9001, host: 9001, auto_correct:true # supervisor
    config.vm.network :forwarded_port, guest: 9200, host: 9200, auto_correct:true # elasticsearch
    config.vm.network :forwarded_port, guest: 27017, host: 27017, auto_correct:true # mongodb

    if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
    end
    config.vm.provision :shell, :path => "project/provision/shell/ubuntu.sh"
    config.vm.provision :puppet do |provision|
        provision.manifests_path ="project/provision/puppet/manifests"
        provision.manifest_file = "site.pp"
        provision.module_path = "project/provision/puppet/modules"
    end
    config.vm.define "local", primary: true do |local|
      host = RbConfig::CONFIG['host_os']

    # Give VM 1/4 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else # sorry Windows folks, I can't help you
      cpus = 2
      mem = 1024
    end
		local.vm.provider "virtualbox" do |provider, override|
			provider.name = VM_NAME
			provider.gui = false
			provider.customize ["modifyvm", :id, "--memory", mem]
      provider.customize ["modifyvm", :id, "--cpus", cpus]
			provider.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
			provider.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      provider.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      override.vm.box = "ubuntu/trusty64"
			override.vm.box_url = "https://vagrantcloud.com/ubuntu/trusty64"
      override.vm.synced_folder ".", "/vagrant", type: 'rsync'
      override.vm.network :private_network, ip: '10.11.12.13'
		end
	end
	config.vm.define "production", autostart: false do |production|
		production.vm.provider :digital_ocean do |provider, override|
			override.ssh.private_key_path = "~/.ssh/id_rsa"
			override.vm.box = "digital_ocean"
			override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
			provider.image = "Ubuntu 14.04 x64"
			provider.size = "1GB"
			provider.region = "London 1"
			provider.client_id = ENV['DIGITAL_OCEAN_CLIENT_ID']
			provider.api_key = ENV['DIGITAL_OCEAN_API_KEY']
			provider.backups_enabled = true
		end
	end
	config.vm.define "lxc", autostart: false do |lxc|
		lxc.vm.provider :lxc do |provider, override|
			provider.container_name = VM_NAME
			provider.customize "cgroup.memory.limit_in_bytes", VM_MEMORY
			override.vm.box = "fgrehm/trusty64-lxc"
			override.vm.box_url = "https://vagrantcloud.com/fgrehm/trusty64-lxc"
		end
	end
end
