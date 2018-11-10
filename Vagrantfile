# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.network "public_network"

  config.vm.network :forwarded_port, host: 8080, guest: 80
  config.vm.network :forwarded_port, host: 8056, guest: 8056
  config.vm.network :forwarded_port, host: 8070, guest: 8070
  config.vm.network :forwarded_port, host: 8071, guest: 8071
  config.vm.network :forwarded_port, host: 8072, guest: 8072
  config.vm.network :forwarded_port, host: 8073, guest: 8073
  
end