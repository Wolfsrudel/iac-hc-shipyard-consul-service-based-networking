#!/bin/bash

# Setup the systemd unit for consul
mkdir -p /etc/consul.d
mkdir -p /opt/consul

cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Add the server config
sudo ln -s /files/config.hcl /etc/consul.d/config.hcl

# Add the Gossip encryption key
export GOSSIP_KEY=$(cat /tokens/gossip.key)

cat <<EOF > /etc/consul.d/gossip.hcl
encrypt = "${GOSSIP_KEY}"
EOF

systemctl daemon-reload
systemctl enable consul
systemctl start consul