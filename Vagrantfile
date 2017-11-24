# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Vagrant Box
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_check_update = true
  
  # Folders
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/tito_ctf"
  
  # Custom Hostname
  config.vm.hostname = "tito"
 
  # Virtualbox Setup
  config.vm.provider "virtualbox" do |vb|
    vb.name   = "tito_ctf_dev"
    vb.cpus   = 2
    vb.memory = "2000"
  end
 
  # Custom Provisioning 
  config.vm.provision "shell", path: "setup/install_apt_https.sh",        privileged: false
  config.vm.provision "shell", path: "setup/update_and_updgrade_apt.sh",  privileged: false
  config.vm.provision "shell", path: "setup/install_ruby.sh",             privileged: false
end
