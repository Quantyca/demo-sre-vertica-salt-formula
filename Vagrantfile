# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|

  # HostManager config
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true

  # Salt Minion 01
  config.vm.define "vertica01" do |vertica01|
    vertica01.vm.box = "generic/centos7"
    vertica01.vm.hostname = "vertica01"
    vertica01.vm.network "private_network", ip: "192.168.99.2"
    vertica01.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.name = "vertica01"
    end
    vertica01.vbguest.auto_update = false
    vertica01.vm.synced_folder '.', '/vagrant', disabled: true
    vertica01.vm.provision "shell", inline: "systemctl stop firewalld; systemctl disable firewalld;"
    vertica01.vm.provision :salt do |salt|
        salt.bootstrap_options = '-A vertica03'
        salt.minion_id = "vertica01"
        salt.masterless = true
        salt.run_highstate = false
        salt.verbose = true
        salt.colorize = true
        salt.log_level = "info"
    end
  end

  # Salt Minion 02
  config.vm.define "vertica02" do |vertica02|
    vertica02.vm.box = "generic/centos7"
    vertica02.vm.hostname = "vertica02"
    vertica02.vm.network "private_network", ip: "192.168.99.3"
    vertica02.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.name = "vertica02"
    end
    vertica02.vbguest.auto_update = false
    vertica02.vm.synced_folder '.', '/vagrant', disabled: true
    vertica02.vm.provision "shell", inline: "systemctl stop firewalld; systemctl disable firewalld;"
    vertica02.vm.provision :salt do |salt|
        salt.bootstrap_options = '-A vertica03'
        salt.minion_id = "vertica02"
        salt.masterless = true
        salt.run_highstate = false
        salt.verbose = true
        salt.colorize = true
        salt.log_level = "info"
    end
  end

  # Salt Minion 03
  config.vm.define "vertica03" do |vertica03|
    vertica03.vm.box = "generic/centos7"
    vertica03.vm.hostname = "vertica03"
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
        salt.bootstrap_options = '-J \'{"auto_accept": true}\' -A vertica03'
        salt.minion_id = "vertica03"
        salt.install_master = true
        salt.verbose = true
        salt.colorize = true
        salt.log_level = "info"
        salt.run_highstate = false
    end
    vertica03.vm.provision "shell", inline: "systemctl stop firewalld; systemctl disable firewalld; echo Sleep for a while to keep salt-minion alive;sleep 60; salt '*' test.ping || sleep 60"
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
