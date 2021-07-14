#!/bin/sh -eux

kickstart='
This system was built with the AppD Cloud Kickstart project by the AppDynamics Cloud Channel Sales Team.
More information can be found at: https://github.com/CiscoDevNet/AppD-Cloud-Kickstart'

if [ -d /etc/update-motd.d ]; then
    MOTD_CONFIG='/etc/update-motd.d/99-kickstart'

    cat >> "$MOTD_CONFIG" <<KICKSTART
#!/bin/sh

cat <<'EOF'
$kickstart
EOF
KICKSTART

    chmod 0755 "$MOTD_CONFIG"
else
    echo "$kickstart" >> /etc/motd
fi
