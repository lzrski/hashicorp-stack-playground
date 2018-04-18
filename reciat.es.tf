resource "digitalocean_domain" "reciat-es" {
   name = "reciat.es"
   ip_address = "${digitalocean_droplet.haproxy-www.ipv4_address}"
}

resource "digitalocean_record" "www-reciate-es" {
  domain = "${digitalocean_domain.reciat-es.name}"
  type = "CNAME"
  name = "www"
  value = "@"
}

resource "digitalocean_record" "app-reciate-es" {
  domain = "${digitalocean_domain.reciat-es.name}"
  type = "CNAME"
  name = "app"
  value = "@"
}
