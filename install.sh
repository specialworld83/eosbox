#!/usr/bin/env bash

PREFIX="/usr/local"

mkdir -p $PREFIX/share/eosbox/bin
install -v -D -m 755 ./eosbox.bash $PREFIX/bin/eosbox
install -v -D -m 755 ./eosbox-desktop.bash $PREFIX/bin/eosbox-desktop
[[ ! -e /etc/eosbox.conf ]] && install -v -D -m 755 ./eosbox.conf /etc/eosbox.conf
install -v -D -m 755 ./copyresolv.bash $PREFIX/share/eosbox/bin/copyresolv
install -v -D -m 755 ./eosboxcommand.bash $PREFIX/share/eosbox/bin/eosbox
install -v -D -m 755 ./remount_run.bash $PREFIX/share/eosbox/bin/remount_run
install -v -D -m 755 ./chroot_setup.bash $PREFIX/share/eosbox/chroot_setup.bash
install -v -D -m 755 ./eosboxinit.bash $PREFIX/share/eosbox/bin/eosboxinit
install -v -D -m 755 ./eosbox.service /usr/lib/systemd/system/eosbox.service
install -v -D -m 755 ./eosbox_remove.bash $PREFIX/bin/eosbox_remove

grep 'PREFIX=' /etc/eosbox.conf >/dev/null 2>&1 || cat << EOF >> /etc/eosbox.conf



# Don't change this unless you know what you're doing.
PREFIX="$PREFIX"
EOF
[[ -z $1 ]] && exit 0

if [ $1 = "--exp" ]; then
	install -v -D -m 755 ./exp/startx-killxdg.bash $PREFIX/bin/startx-killxdg
else
	echo "Unknown install option: $1"
fi
