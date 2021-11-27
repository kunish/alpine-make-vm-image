#! /bin/sh

_step_counter=0
step() {
  _step_counter=$((_step_counter + 1))
  printf '\n\033[1;36m%d) %s\033[0m\n' $_step_counter "$@" >&2
}

step 'Set up timezone'
setup-timezone -z Asia/Shanghai

step 'Set up networking'
cat >/etc/network/interfaces <<-EOF
	iface lo inet loopback
	iface eth0 inet dhcp
EOF
ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0

step 'Adjust rc.conf'
sed -Ei \
  -e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
  -e 's/^[# ](rc_logger)=.*/\1=YES/' \
  -e 's/^[# ](unicode)=.*/\1=YES/' \
  /etc/rc.conf

step 'Enable services'
rc-update add acpid
rc-update add chronyd
rc-update add crond
rc-update add docker
rc-update add net.eth0
rc-update add net.lo
rc-update add open-vm-tools
rc-update add sshd
rc-update add termencoding

step 'Setup shell'
chsh -s /usr/bin/fish
touch .hushlogin
mkdir -p ~/.config/fish
cat >~/.config/fish/config.fish <<-EOF
set -x fish_greeting
EOF
