# Setup data dir
data_dir = "/tmp/server"

server {
    enabled = true

    bootstrap_expect = 3

    retry_join = [ "load-balancer" ]
}

consul {
  address = "localhost:8500"
}
