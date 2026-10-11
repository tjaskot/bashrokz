systemctl status vastai vast_metrics 2>/dev/null
journalctl -u vastai -n 100 --no-pager
ls /var/lib/vastai_kaalia/
tail -n 100 /var/lib/vastai_kaalia/kaalia.log

mkdir /tmp/vcheck && tar -xzvf <file>.tgz -C /tmp/vcheck
tar -tzvf <file>.tgz | head -50     # list contents without extracting
gzip -t <file>.tgz                   # integrity test

mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

ssh-keygen -t ed25519
ssh-copy-id machine@ip
ssh machine@ip

sudo vim /etc/ssh/sshd_config
# update to passwordauthentication no
grep -ri PasswordAuthentication /etc/ssh/sshd_config /etc/ssh/sshd_config.d/
sudo sshd -T | grep -i passwordauthentication
