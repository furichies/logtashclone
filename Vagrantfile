# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # WordPress VM
  config.vm.define "wordpress-vm" do |wp|
    wp.vm.hostname = "wordpress"
    wp.vm.network "private_network", ip: "192.168.33.10"
    wp.vm.provider "virtualbox" do |vb|
      vb.name = "wordpressmachine"
      vb.memory = "2048"
      vb.cpus = "2"
    end  
     
    wp.vm.provision "shell", path: "wordpress.sh"
  end


  # ELK VM
  config.vm.define "elk-vm" do |elk|
    elk.vm.hostname = "elastic"
    elk.vm.network "private_network", ip: "192.168.33.20"
    elk.vm.network "forwarded_port", guest: 5601, host: 5601
    elk.vm.network "forwarded_port", guest: 9200, host: 9200

    elk.vm.provider "virtualbox" do |vb|
      vb.name = "elasticmachine"
      vb.memory = "4096"
      vb.cpus = "2"
    end

    elk.vm.provision "shell", path: "elk.sh"
 
  end
end
