resource "digitalocean_domain" "default" {
   name = "reciate.community"
   ip_address = "${digitalocean_droplet.haproxy-www.ipv4_address}"
}

resource "digitalocean_record" "www-reciate-community" {
  domain = "${digitalocean_domain.default.name}"
  type = "CNAME"
  name = "www"
  value = "@"
}

resource "digitalocean_record" "app-reciate-community" {
  domain = "${digitalocean_domain.default.name}"
  type = "CNAME"
  name = "app"
  value = "@"
}
