# Setup data dir
data_dir = "/tmp/client"

client {
  enabled = true
  servers = [
    "localhost:4647",
    "load-balancer:4647"
  ]
}

ports {
    http = 5656
}

consul {
  address = "localhost:8500"
}
