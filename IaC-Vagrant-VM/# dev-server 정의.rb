  # dev-server 정의
  config.vm.define "dev-server" do |dev|
    dev.vm.box = "generic/rocky9"
    dev.vm.hostname = "dev-server"
    #dev.vm.network "private_network", ip: "192.168.56.11"
    dev.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = "2"
    end
    # 자동 프로비저닝 설정
    dev.vm.provision "shell", path: "provision_dev.sh"
  end