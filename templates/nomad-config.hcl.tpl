
# Enable the server
data_dir   = "/var/nomad/data"

server {
  enabled = true
  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = 3
}

client {
  enabled = true
}
