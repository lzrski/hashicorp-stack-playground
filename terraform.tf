# data "digitalocean_image" "base-image" {
#   name = "base.2017.12.23.8"
# }

variable "region" { default = "ams3" }
variable "do_token" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "prime" {
  count  = 3
  image  = "ubuntu-16-04-x64"
  name   = "${format("%s-%02d-%s", "prime", count.index + 1, var.region)}"
  region = "${var.region}"
  size   = "512mb"
  ssh_keys = [ "${var.ssh_fingerprint}" ]

  provisioner "file" {
    source = "provision/bin/"
    destination = "/usr/bin"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /usr/bin/consul",
      "chmod a+x /usr/bin/nomad",
    ]
  }
}

resource "digitalocean_droplet" "worker" {
 count  = 5
 image  = "ubuntu-16-04-x64"
 name   = "${format("%s-%02d-%s", "worker", count.index + 1, var.region)}"
 region = "${var.region}"
 size   = "512mb"
 ssh_keys = [ "${var.ssh_fingerprint}" ]

 provisioner "file" {
   source = "provision/bin/"
   destination = "/usr/bin"
 }

 provisioner "remote-exec" {
   inline = [
     "chmod a+x /usr/bin/consul",
     "chmod a+x /usr/bin/nomad",
   ]
 }
}

output "prime-ipv4" {
  value = "${digitalocean_droplet.prime.*.ipv4_address}"
}

output "worker-ipv4" {
 value = "${digitalocean_droplet.worker.*.ipv4_address}"
}
