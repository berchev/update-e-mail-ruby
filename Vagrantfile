Vagrant.configure("2") do |config|
  
  config.vm.define "mysql01" do |node|
    node.vm.box = "berchev/mysql64"
    node.vm.hostname = "mysql01"
    node.vm.network "private_network", ip: "192.168.56.11"
    node.vm.network :forwarded_port, guest: 3306, host: 3306 # MySQL 
    node.vm.provision :shell, path: "scripts/mysql01_provision.sh"
  end 

  config.vm.define "vault01" do |node|
    node.vm.box = "berchev/xenial64"
    node.vm.hostname = "vault01"
    node.vm.network "private_network", ip: "192.168.56.31"
    node.vm.network :forwarded_port, guest: 8200, host: 8200 # Vault
    node.vm.provision :shell, path: "scripts/vault01_provision.sh"
  end

  config.vm.define "app01" do |node|
    node.vm.box = "berchev/xenial64"
    node.vm.hostname = "app01"
    node.vm.network "private_network", ip: "192.168.56.21"
    node.vm.provision :shell, path: "scripts/app01_provision.sh"
  end
  
end
