resource "digitalocean_droplet" "www-1" {
  image = "ubuntu-16-04-x64"
  name = "www-1"
  region = "ams3"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  connection {
    user = "root"
    type = "ssh"
    agent = true
    # private_key = "${file(var.private_key)}"
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install nginx
      "sudo apt-get update",
      "sudo apt-get -y install nginx"
    ]
  }

  provisioner "file" {
    source = "index-1.html"
    destination = "/var/www/html/index.html"
  }
}
