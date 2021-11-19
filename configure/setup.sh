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
rc-update add net.lo boot
rc-update add open-vm-tools boot
rc-update add sshd boot
rc-update add termencoding boot

rc-update add acpid default
rc-update add chronyd default
rc-update add crond default
rc-update add docker default
rc-update add net.eth0 default

step 'Setup shell'
chsh -s /usr/bin/fish
