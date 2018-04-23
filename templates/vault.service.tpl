[Unit]

Description=Vault Service
Requires=network-online.target
After=network-online.target

[Service]

EnvironmentFile=-/etc/sysconfig/vault
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/sbin/vault server -config=/etc/vault.d/
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]

WantedBy=multi-user.target
