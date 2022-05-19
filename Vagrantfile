# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/focal64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
    # Customize the amount of memory on the VM:
    vb.memory = "8192"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    set -e
    # https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems
    OS=xUbuntu_20.04
    VERSION=1.24 # kubeadm version

    echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list 
    echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

    mkdir -p /usr/share/keyrings
    curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
    curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

    apt-get update
    apt-get install cri-o cri-o-runc -y

    echo "Successfully installed cri-o and cri-o-runc"

    # https://github.com/kata-containers/kata-containers/blob/main/docs/install/snap-installation-guide.md
    snap install kata-containers --stable --classic
    mkdir -p /etc/kata-containers
    cp /snap/kata-containers/current/usr/share/defaults/kata-containers/configuration.toml /etc/kata-containers/
    ln -sf /snap/kata-containers/current/usr/bin/containerd-shim-kata-v2 /usr/local/bin/containerd-shim-kata-v2

    echo "Successfully installed kata-containers"

    systemctl daemon-reload
    systemctl enable crio
    systemctl start crio

    # Install Go
    VERSION="1.18.2" # go version
    ARCH="amd64" # go architecture
    curl -O -L "https://golang.org/dl/go${VERSION}.linux-${ARCH}.tar.gz"
    rm -rf /usr/local/go && tar -C /usr/local -xzf go${VERSION}.linux-${ARCH}.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    go version

    # Install crictl
    VERSION=v1.24.1
    wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
    tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
    rm -f crictl-$VERSION-linux-amd64.tar.gz
    crictl version

    # Install kubeadm, kubelet, kubectl
    ss -tulpn # check to see if 6443 is not being used
    swapoff -a # there shouldn't be any swap configs in /etc/fstab regardless in this image
    lscpu # make sure you have at least 2 CPUs
    free -h # make sure you have at least 2G of RAM
    
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    # Configure cgroups for k8s
    echo -e "[crio.runtime]\nconmon_cgroup = \"pod\"\ncgroup_manager = \"cgroupfs\"" > /etc/crio/crio.conf.d/02-cgroup-manager.conf

    # Configure IP forwarding
    modprobe br_netfilter
    echo 1 > /proc/sys/net/ipv4/ip_forward

    kubeadm init

    # set up default user for kubectl
    USER=vagrant
    mkdir -p /home/$USER/.kube
    cp -i /etc/kubernetes/admin.conf /home/$USER/.kube/config
    chown $(id -u $USER):$(id -g $USER) /home/$USER/.kube/config
    
    export KUBECONFIG=/etc/kubernetes/admin.conf

    # Network plugin install
  SHELL
end
