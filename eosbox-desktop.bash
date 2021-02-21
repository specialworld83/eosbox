#!/usr/bin/env bash

source /etc/eosbox.conf

install_desktop(){
    mkdir -p ~/.local/share/applications/eosbox
    for i in $@; do
        eosbox readlink /usr/share/applications/$i >/dev/null 2>&1 \
            && cp $CHROOT/$(eosbox readlink /usr/share/applications/$i) ~/.local/share/applications/eosbox \
            || cp $CHROOT/usr/share/applications/$i ~/.local/share/applications/eosbox 
        sed -i 's/Exec=/Exec=eosbox\ /g' ~/.local/share/applications/eosbox/$i
        sed -i '/TryExec=/d' ~/.local/share/applications/eosbox/$i
    done
}

checkdep(){
    hash $1 2>/dev/null || err "Install $1!"
}

err(){
    echo "$(tput bold)$(tput setaf 1)==> $@ $(tput sgr0)" 1>&2
    exit 1
}

help_text(){
cat << EOF
USAGE: $0 <arguments>

OPTIONS:
  -i, --install FILE    Installs desktop entries in /usr/share/applications
  -r, --remove FILE     Removes desktop entries in ~/.local/share/applications/eosbox
  -l, --list            List available desktop entries
  -s, --list-installed  List installed desktop entries
  -h, --help            Displays this help message

EOF
}

case $1 in 
    -i|--install)
        checkdep update-desktop-database
        install_desktop ${@:2}
        update-desktop-database
        exit $?
    ;;
    -r|--remove)
        checkdep update-desktop-database
        selected_entry=${@:2}
        for i in $selected_entry; do
            rm ~/.local/share/applications/eosbox/$i
        done
        update-desktop-database
        exit $?
    ;;
    -h|--help)
        help_text
        exit 0
    ;;
    -l|--list)
        eosbox ls -1 --color=none /usr/share/applications
        exit $?
    ;;
    -s|--list-installed)
        ls -1 --color=none ~/.local/share/applications/eosbox
        exit $?
    ;;
    *)
        checkdep zenity
        checkdep sed
        checkdep update-desktop-database
        action="$(zenity --list --radiolist --title 'Archbox Desktop Manager' \
            --height=200 --width=450 --column 'Select' --column 'Action' \
            --text 'What do you want to do?' \
             FALSE 'Install desktop entries' FALSE 'Remove desktop entries')"
        case $action in
            'Install desktop entries')
                list_desktop="$(eosbox ls --color=none -1 /usr/share/applications)"
                zenity_entry="$(echo $list_desktop | sed 's/\ /\ FALSE\ /g')"
                selected_entry=$(zenity --list --checklist --height=500 --width=450 \
                    --title="Archbox Desktop Manager" \
                    --text "Select .desktop entries those you want to install" \
                    --column "Select" --column "Applications" \
                    FALSE $zenity_entry | sed 's/|/\ /g')
                [[ -z $selected_entry ]] && exit 1
                install_desktop $selected_entry
                update-desktop-database
                exit 0
            ;;
            'Remove desktop entries')
                list_desktop="$(ls --color=none -1 ~/.local/share/applications/eosbox)"
                [[ -z $list_desktop ]] && zenity --info --title "Archbox Desktop Manager" \
                    --text "No .desktop files installed" --width=300 && exit 1
                zenity_entry="$(echo $list_desktop | sed 's/\ /\ FALSE\ /g')"
                selected_entry=$(zenity --list --checklist --height=500 --width=450 \
                --title="Archbox Desktop Manager" \
                --text "Select .desktop entries those you want to remove" \
                --column "Select" --column "Applications" \
                FALSE $zenity_entry | sed 's/|/\ /g')
                [[ -z $selected_entry ]] && exit 1
                for i in $selected_entry; do
                    rm ~/.local/share/applications/eosbox/$i
                done
                update-desktop-database
                exit $?
            ;;
        esac
        exit 1
    ;;
esac    
