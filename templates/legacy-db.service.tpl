[Unit]

Description=Legacy DB SSH tunnel Service
Requires=network-online.target
After=network-online.target

[Service]

EnvironmentFile=-/etc/sysconfig/legacy-db
Restart=on-failure
ExecStart=/usr/bin/ssh ${bastion_user}@${bastion_host} \
  -L 54322:${staging_db_host}:${staging_db_port} \
  -N -T -C \
  -o ExitOnForwardFailure=yes \
  -o StrictHostKeyChecking=no
KillSignal=SIGINT

[Install]

WantedBy=multi-user.target
