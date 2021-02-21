#!/usr/bin/env bash

source /etc/eosbox.conf
source /tmp/eosbox_env

case $1 in 
    killxdg)
        umount -l $CHROOT/run
        fuser -km $XDG_RUNTIME_DIR
        exit $?
    ;;
    runtimeonly)
        mkdir -p $CHROOT$XDG_RUNTIME_DIR
        umount -Rl $CHROOT$XDG_RUNTIME_DIR 2>/dev/null
        mount | grep $CHROOT$XDG_RUNTIME_DIR || \
            mount --rbind $XDG_RUNTIME_DIR $CHROOT$XDG_RUNTIME_DIR
        exit $?
    ;;
    *)
        umount -l $CHROOT/run
        mount --rbind /run $CHROOT/run
        exit $?
    ;;
esac
