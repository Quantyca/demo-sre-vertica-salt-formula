# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true

  config.vm.define "vertica01" do |vertica01|
    vertica01.vm.box = "centos/7"
    vertica01.vm.box_version = "1811.01"
    vertica01.vm.network "private_network", ip: "192.168.99.2"
    vertica01.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.name = "vertica01"
    end
    vertica01.vbguest.auto_update = false
    vertica01.vm.synced_folder '.', '/vagrant', disabled: true
    vertica01.vm.provision :salt do |salt|
        salt.minion_config = "vagrant/config/minion1"
        salt.minion_id = vertica01
        salt.masterless = true
        salt.run_highstate = false
        salt.verbose = true
        salt.colorize = true
        salt.log_level = "info"
        salt.minion_key = "vagrant/pki/vertica01.pem"
        salt.minion_pub = "vagrant/pki/vertica01.pub"
    end
  end

  config.vm.define "vertica02" do |vertica02|
    vertica02.vm.box = "centos/7"
    vertica02.vm.box_version = "1811.01"
    vertica02.vm.network "private_network", ip: "192.168.99.3"
    vertica02.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.name = "vertica02"
    end
    vertica02.vbguest.auto_update = false
    vertica02.vm.synced_folder '.', '/vagrant', disabled: true
    vertica02.vm.provision :salt do |salt|
        salt.minion_config = "vagrant/config/minion2"
        salt.minion_id = vertica02
        salt.masterless = true
        salt.run_highstate = false
        salt.verbose = true
        salt.colorize = true
        salt.log_level = "info"
        salt.minion_key = "vagrant/pki/vertica02.pem"
        salt.minion_pub = "vagrant/pki/vertica02.pub"
    end
  end

  config.vm.define "vertica03" do |vertica03|
    vertica03.vm.box = "centos/7"
    vertica03.vm.box_version = "1811.01"
    vertica03.vm.network "private_network", ip: "192.168.99.4"
    vertica03.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.name = "vertica03"
    end
    vertica03.vm.synced_folder ".", "/shared"
    vertica03.vm.synced_folder "./salt", "/srv/salt/"
    vertica03.vm.synced_folder "./pillar", "/srv/pillar/"
    vertica03.vm.synced_folder '.', '/vagrant', disabled: true
    vertica03.vm.provision :salt do |salt|
        salt.minion_config = "vagrant/config/minion3"
        salt.master_config = "vagrant/config/master"
        salt.minion_id = vertica03
        salt.install_master = true
        salt.verbose = true
        salt.colorize = true
        salt.log_level = "info"
        salt.master_key = "vagrant/pki/master.pem"
        salt.master_pub = "vagrant/pki/master.pub"
        salt.minion_key = "vagrant/pki/vertica03.pem"
        salt.minion_pub = "vagrant/pki/vertica03.pub"
        salt.run_highstate = false
    end
    vertica03.vm.provision "shell", inline: "echo Sleep for a while to keep salt-minion alive;sleep 60; salt '*' test.ping || sleep 60"
    vertica03.vm.provision :salt do |salt1|
        salt1.install_master = true
        salt1.no_minion = true
        salt1.orchestrations = ['vertica.orchestration']
        salt1.verbose = true
        salt1.colorize = true
        salt1.log_level = "info"
    end
  end
end
