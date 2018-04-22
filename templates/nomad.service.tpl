[Unit]

Description=Nomad Agent
Requires=network-online.target
After=network-online.target

[Service]

EnvironmentFile=-/etc/sysconfig/nomad
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/sbin/nomad agent -config=/etc/nomad.d/
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]

WantedBy=multi-user.target
