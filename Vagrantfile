# Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.synced_folder ".", "/vagrant", disabled: false
  config.vm.network "private_network", ip: "192.168.56.101"
  config.vm.network "forwarded_port", guest: 3000, host: 8081
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 22, host: 2222

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y git net-tools jq tree make wget apt-transport-https ca-certificates curl software-properties-common
      sudo apt-get install -y docker.io
      sudo usermod -aG docker vagrant
      sudo systemctl enable docker
      sudo systemctl start docker
SHELL
end
