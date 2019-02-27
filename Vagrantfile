# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|

  config.vm.define "vertica01" do |vertica01|
    vertica01.vm.box = "centos/7"
    vertica01.vm.box_version = "1811.01"
    vertica01.vm.network "private_network", ip: "192.168.99.2"
    vertica01.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
    end
    vertica01.vm.synced_folder ".", "/shared"
    vertica01.vm.synced_folder "./salt", "/srv/salt/"
    vertica01.vm.synced_folder '.', '/vagrant', disabled: true
    vertica01.vm.provision :salt do |salt|
        salt.install_type = "git"
        salt.version = "2018.3.4"
        salt.minion_config = "salt/minion1"
        salt.minion_id = vertica01
        salt.masterless = true
        salt.run_highstate = false
        salt.verbose = true
        salt.colorize = true
        salt.log_level = "info"
        salt.minion_key = "salt/key/vertica01.pem"
        salt.minion_pub = "salt/key/vertica01.pub"
    end
  end

  config.vm.define "vertica02" do |vertica02|
    vertica02.vm.box = "centos/7"
    vertica02.vm.box_version = "1811.01"
    vertica02.vm.network "private_network", ip: "192.168.99.3"
    vertica02.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
    end
    vertica02.vm.synced_folder ".", "/shared"
    vertica02.vm.synced_folder "./salt", "/srv/salt/"
    vertica02.vm.synced_folder '.', '/vagrant', disabled: true
    vertica02.vm.provision :salt do |salt|
        salt.install_type = "git"
        salt.version = "2018.3.4"
        salt.minion_config = "salt/minion2"
        salt.minion_id = vertica02
        salt.masterless = true
        salt.run_highstate = false
        salt.verbose = true
        salt.colorize = true
        salt.log_level = "info"
        salt.minion_key = "salt/key/vertica02.pem"
        salt.minion_pub = "salt/key/vertica02.pub"
    end
  end

  config.vm.define "vertica03" do |vertica03|
    vertica03.vm.box = "centos/7"
    vertica03.vm.box_version = "1811.01"
    vertica03.vm.network "private_network", ip: "192.168.99.4"
    vertica03.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
    end
    vertica03.vm.synced_folder ".", "/shared"
    vertica03.vm.synced_folder "./salt", "/srv/salt/"
    vertica03.vm.synced_folder "./pillar", "/srv/pillar/"
    vertica03.vm.synced_folder '.', '/vagrant', disabled: true
    vertica03.trigger.before :up do |trigger|
      trigger.info = "Wait 1 minute"
      trigger.ruby do |env,machine|
      sleep(60)
      end
    end
    vertica03.vm.provision :salt do |salt|
        salt.install_type = "git"
        salt.version = "2018.3.4"
        salt.minion_config = "salt/minion3"
        salt.master_config = "salt/master"
        salt.minion_id = vertica03
        salt.install_master = true
        salt.orchestrations = ['setups.vertica.cluster.9_1_0-0.orchestration']
        salt.verbose = true
        salt.colorize = true
        salt.log_level = "info"
        salt.master_key = "salt/key/master.pem"
        salt.master_pub = "salt/key/master.pub"
        salt.minion_key = "salt/key/vertica03.pem"
        salt.minion_pub = "salt/key/vertica03.pub"
        salt.pillar({
          "dev" => "/dev/sda1"
          }
        )
        salt.seed_master = {"vertica01": "salt/key/vertica01.pub", "vertica02": "salt/key/vertica02.pub", "vertica03": "salt/key/vertica03.pub"}
    end
  end
end
