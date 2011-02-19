# Seal this server off from being able to login with passwords

# Backup sshd_config file if we haven't already done so
[ -e /etc/ssh/sshd_config.original ] || cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
# Turn off password authentication
cat /etc/ssh/sshd_config |sed 's/^UsePAM yes/UsePAM no/'|sed 's/^#PasswordAuthentication \(yes\|no\)/PasswordAuthentication no/' >/etc/ssh/sshd_config

# Backup sudoers file if we haven't already done so
[ -e /etc/sudoers.original ] || cp /etc/sudoers /etc/sudoers.original
# Let our users in the sudo group elevate themselves to root without a password
cat /etc/sudoers.original |sed 's/^%sudo ALL=.*$/%sudo ALL=(ALL) NOPASSWD: ALL/' >/etc/sudoers
