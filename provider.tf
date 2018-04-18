variable "do_token" {}
variable "public_key" {}
variable "private_key" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}
