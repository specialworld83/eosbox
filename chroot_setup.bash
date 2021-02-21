#!/usr/bin/env bash

err(){
    echo "$(tput bold)$(tput setaf 1)==> $@ $(tput sgr0)" 1>&2
    exit 1
}

msg(){
    echo "$(tput bold)$(tput setaf 2)==> $@ $(tput sgr0)"
}

PATH=/usr/bin
msg "Initializing pacman keyrings..."
pacman-key --init
pacman-key --populate archlinux
msg "Installing essential packages..."
pacman -Syu base base-devel xorg pulseaudio nano wget lsb-release neofetch noto-fonts ttf-dejavu --noconfirm
msg "Installing EOS package and keyring..."
wget https://mirror.linux.pizza/endeavouros/repo/endeavouros/x86_64/endeavouros-keyring-1-5-any.pkg.tar.zst 
wget https://mirror.linux.pizza/endeavouros/repo/endeavouros/x86_64/eos-hooks-1.4.1-1-any.pkg.tar.zst
wget https://mirror.linux.pizza/endeavouros/repo/endeavouros/x86_64/endeavouros-mirrorlist-3.3-1-any.pkg.tar.zst
cd / 
pacman -U endeavouros-keyring-1-5-any.pkg.tar.zst
pacman -U eos-hooks-1.4.1-1-any.pkg.tar.zst
pacman -U endeavouros-mirrorlist-3.3-1-any.pkg.tar.zst
msg "Remove download packages"
cd /
rm -rf endeavouros-keyring-1-5-any.pkg.tar.zst eos-hooks-1.4.1-1-any.pkg.tar.zst endeavouros-mirrorlist-3.3-1-any.pkg.tar.zst 
msg "Installing eosboxctl..."
mkdir -p /usr/local/bin
curl https://raw.githubusercontent.com/lemniskett/archboxctl/master/archboxctl.bash > /usr/local/bin/eosboxctl
chmod 755 /usr/local/bin/eosboxctl
wget https://raw.githubusercontent.com/endeavouros-team/EndeavourOS-archiso/master/pacman.conf
cd /
cp -rv pacman.conf /etc/pacman.conf
msg "Remove pacman.conf"
cd /
rm -rf pacman.conf
msg "Setting up locale..."
echo "Uncomment needed locale, enter to continue"
read
nano /etc/locale.gen
locale-gen
msg "Setting up timezone..."
echo "Enter your timezone, for example : \"Asia/Jakarta\"" 
while true; do
	read TIMEZONE \
		&& [[ -e /usr/share/zoneinfo/$TIMEZONE ]] \
		&& ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
		&& break \
		|| echo "Timezone not found, enter it again."
done
msg "Creating user account..."
CHROOT_USER="$(cat /tmp/eosbox_user)"
useradd -m $CHROOT_USER
gpasswd -a $CHROOT_USER wheel
echo "Enter root password"
while true; do
	passwd && break
done
echo "Enter $CHROOT_USER password"
while true; do
	passwd $CHROOT_USER && break
done
sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
msg "Run sudo systemctl enable eosbox.service"
msg "Run eosbox sudo pacman -Syu yay"
#echo "Don't forget to run \"eosbox --mount\" in host on boot"
