# -*- mode: ruby -*-
# vi: set ft=ruby :

def vault_server (docker)
  docker.run "vault",
    cmd: "vault server -dev",
    args: "--net=host"
end

def consul_server (docker, address, extra_args = "")
  docker.run "consul",
    cmd: """consul agent \
        -server \
        -bind=#{address} \
        -data-dir=/consul/data \
        -bootstrap-expect=3 \
        -retry-join=load-balancer \
        #{extra_args}
    """,
    args: "--net=host"
end

def nomad_server (docker, address, extra_args = "")
  docker.run "nomad-server",
    image: "djenriquez/nomad",
    cmd: "agent --config=/etc/nomad.d/server.hcl",
    args: """ \
      --net=host \
      --volume '/vagrant/nomad.d:/etc/nomad.d' \
      --volume '/opt/nomad:/opt/nomad' \
      --volume '/var/run/docker.sock:/var/run/docker.sock' \
      #{extra_args} \
    """
end

def nomad_client (docker, address, extra_args = "")
  docker.run "nomad-client",
    image: "djenriquez/nomad",
    cmd: "agent --config=/etc/nomad.d/client.hcl",
    args: """ \
      --net=host \
      --volume '/vagrant/nomad.d:/etc/nomad.d' \
      --volume '/opt/nomad:/opt/nomad' \
      --volume '/var/run/docker.sock:/var/run/docker.sock' \
      #{extra_args} \
    """
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :hosts do |hosts|
    hosts.autoconfigure = true
    hosts.sync_hosts = true
  end

  config.ssh.forward_agent = true

  config.vm.define "bastion", primary: true do |node|
    address = "10.0.0.101"

    node.vm.network :private_network, ip: address
    node.vm.hostname = "bastion"

    node.vm.provision :docker do |docker|
      consul_server docker, address
      nomad_server docker, address
      nomad_client docker, address
    end
  end

  config.vm.define "api" do |node|
    address = "10.0.0.103"
    node.vm.network :private_network, ip: address
    node.vm.hostname = "api"

    node.vm.provision :docker do |docker|
      consul_server docker, address
      nomad_server docker, address
      nomad_client docker, address
    end
  end

  config.vm.define "db" do |node|
    address = "10.0.0.104"

    node.vm.network :private_network, ip: address
    node.vm.hostname = "db"

    node.vm.provision :docker do |docker|
      consul_server docker, address
      nomad_server docker, address
      nomad_client docker, address
    end
  end

  config.vm.define "load-balancer" do |node|
    address = "10.0.0.102"

    node.vm.network :forwarded_port, guest: 9999, host: 9999 # Fabio LB
    node.vm.network :forwarded_port, guest: 9998, host: 9998 # Fabio UI
    node.vm.network :forwarded_port, guest: 8500, host: 8500 # Consul
    node.vm.network :forwarded_port, guest: 4646, host: 4646 # Nomad

    node.vm.network :private_network, ip: address
    node.vm.hostname = "load-balancer"

    node.vm.provision :docker do |docker|
      # consul_server docker, address, "-ui -client=#{address}"
      consul_server docker, address, "-ui -client=0.0.0.0"
      nomad_server docker, address
      nomad_client docker, address

      docker.run "fabiolb/fabio",
        args: "--net=host",
        name: "fabio"
    end
  end

end
