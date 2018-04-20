variable "region" { default = "ams3" }
variable "do_token" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

data "template_file" "consul-config" {
  template = "${file("templates/consul-config.json.tpl")}"
}

data "template_file" "consul-service" {
  template = "${file("templates/consul.service.tpl")}"
}

# resource "digitalocean_droplet" "base" {
#   # This droplet is used to make a base image for quick rebuilds.
#   # After creating it, power it off, go to DigitlOcean dashboard and take a snapshot.
#   # Then comment it out, so next time it will be destroyed.
#   # This should really be done with Packer, see here:
#   #   http://benvogt.io/blog/architecture-with-packer-terraform-nomad-consul/

#   image = "ubuntu-16-04-x64"
#   name = "consul-nomad-base"
#   region = "${var.region}"
#   size   = "512mb"
#   ssh_keys = [ "${var.ssh_fingerprint}" ]
#   private_networking = true
#
#   # Copy HashiCorp binaries
#   provisioner "file" {
#     source = "provision/bin/"
#     destination = "/usr/local/sbin"
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "apt update"
#       "apt upgrade --yes"
#       "apt install --yes httpie jq unzip"
#       "chmod a+x /usr/local/sbin/consul",
#       "chmod a+x /usr/local/sbin/nomad",
#       "mkdir -p /etc/consul.d",
#       "mkdir -p /var/consul/data",
#     ]
#   }
# }

data "digitalocean_image" "prime" {
  name = "consul-nomad-base"
}

resource "digitalocean_droplet" "prime" {
 count  = 3
 image  = "${data.digitalocean_image.prime.image}"
 name   = "${format("%s-%02d-%s", "prime", count.index + 1, var.region)}"
 region = "${var.region}"
 size   = "512mb"
 ssh_keys = [ "${var.ssh_fingerprint}" ]
 private_networking = true

 provisioner "file" {
   content = "${data.template_file.consul-service.rendered}"
   destination = "/etc/systemd/system/consul.service"
 }

 provisioner "file" {
   content = "${data.template_file.consul-config.rendered}"
   destination = "/etc/consul.d/server.json"
 }

 # This is a custom configuration for each particular droplet
 # The tricky part is that each node needs to bind to it's own private IP address and exactly one needs to be in bootstrap mode.
 # TODO: Why can't I use templates for this? Can I?
 provisioner "file" {
   content = "{ \"bind_addr\": \"${ self.ipv4_address_private }\", \"bootstrap\": ${ count.index == 0 }  }"
   destination = "/etc/consul.d/custom.json"
 }

 provisioner "remote-exec" {
   inline = [
     "systemctl enable consul.service",
     "systemctl start consul.service"
   ]
 }
}

resource "null_resource" "consul-cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", digitalocean_droplet.prime.*.ipv4_address_private)}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(digitalocean_droplet.prime.*.ipv4_address, 0)}"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "consul join ${join(" ", digitalocean_droplet.prime.*.ipv4_address_private)}",
    ]
  }
}


# resource "digitalocean_droplet" "worker" {
#   count  = 1
#   image  = "ubuntu-16-04-x64"
#   name   = "${format("%s-%02d-%s", "worker", count.index + 1, var.region)}"
#   region = "${var.region}"
#   size   = "512mb"
#   ssh_keys = [ "${var.ssh_fingerprint}" ]
#   private_networking = true
#
#   provisioner "file" {
#     source = "provision/bin/"
#     destination = "/usr/local/sbin"
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "chmod a+x /usr/local/sbin/consul",
#       "chmod a+x /usr/local/sbin/nomad",
#     ]
#   }
# }

output "prime-ipv4" {
  value = "${digitalocean_droplet.prime.*.ipv4_address}"
}

output "prime-ipv4-private" {
  value = "${digitalocean_droplet.prime.*.ipv4_address_private}"
}

# output "worker-ipv4" {
#   value = "${digitalocean_droplet.worker.*.ipv4_address}"
# }
