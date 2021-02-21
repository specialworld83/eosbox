# EOSbox is fork Archbox
Installs EndeavourOS inside a chroot environment and tested on Fedora 33
## Why?
Ever since I'm running some niche distros like Void, Solus, I had a problem finding softwares I need in their not-so-large repositories, also I don't like how flatpak and snap works. so i decided to create an EndeavourOS chroot environment everytime I distrohop. Why EndeavourOS? They have a really, really good repositories, oh and don't mention how big AUR is.
## Installation
### Dependencies
- Bash
- Sed
- Curl
- Wget (Optional: use ```wget``` when it's installed)
- Aria2 (Optional: use ```aria2c``` when it's installed)
- Tar
- Desktop-file-utils
- Xorg-xhost (Optional: allowing users in EOSbox to access X server)
- Zenity (Optional: for .desktop entry manager GUI)
### Installing EOSbox
It's pretty easy, just run ```install.sh``` as root.
### Installing chroot environment
Before creating chroot environment, edit your chroot username in ```/etc/eosbox.conf```, then do :
```
sudo eosbox --create <archlinux tarball download link>
```
### Configuring filesystem automount
Execute ```systemctl``` on boot.
If you use systemd, you can create a systemd service with this syntax below (Assuming the install prefix is ```/usr/local```) :
```
sudo systemctl enable eosbox.service
```

If you don't use systemd, either create your own init service, or create a @reboot cronjob.
### Removing chroot environment
**IMPORTANT**, Make sure you've unmounted everything in chroot environment, it's better to remove the init script and reboot to unmount everything. if you can't reboot for some reason, do :
```
sudo eosbox_remove
```
make sure there's no mounted EOSbox directories and then delete the EndeavourOS directory (Assuming the INSTALL_PATH is /var/archlinux) :
```
rm -rf /var/archlinux
```
### Entering chroot environment
To enter chroot, do :
```
eosbox --enter
```
### Executing commands in chroot environment
To execute commands inside chroot environment, do :
```
eosbox <command>
```
for example, to update chroot, do :
```
eosbox sudo pacman -Syu
```
### Optional steps
You may want to add these rules if you don't want to use EOSbox without password (assuming the install prefix is ```/usr/local``` and you're in group ```wheel```) :
Fedora enable wheel into /etc/sudoers
#### Sudo
```
%wheel  ALL=(root) NOPASSWD: /usr/local/share/eosbox/bin/eosbox,/usr/local/share/eosbox/bin/copyresolv,/usr/local/share/eosbox/bin/remount_run,/usr/local/share/eosbox/bin/eosboxinit
```
#### Doas
```
permit nopass :wheel as root cmd /usr/local/share/eosbox/bin/eosbox
permit nopass :wheel as root cmd /usr/local/share/eosbox/bin/copyresolv
permit nopass :wheel as root cmd /usr/local/share/eosbox/bin/remount_run
permit nopass :wheel as root cmd /usr/local/share/eosbox/bin/eosboxinit
```
### Misc
#### Systemd services
Use ```eosboxctl``` command to manage systemd services.


This isn't actually using systemd to start services, rather it parses systemd .service files and executes it.

##### Autostart services
To enable service on host boot, edit `/etc/eosbox.conf` :
```
SERVICES=( vmware-networks-configuration vmware-networks vmware-usbarbitrator nginx )
```
Keep in mind that this doesn't resolve service dependencies, so you may need to enable the dependencies manually. you can use ```eosboxctl desc <service>``` to read the .service file

##### Post-exec delay
Services are asynchronously started, if some services have some issues when starting together you may want to add post-exec delay.
```
SERVICES=( php-fpm:3 nginx )
```

This will add 3 seconds delay after executing php-fpm.
##### Start services immediately
To start services immediately, in EOSbox, do :
```
sudo eosboxctl exec <Service name>
```

##### Custom command on boot
You can create a shell script located at ```/etc/eosbox.rc``` and ```eosboxinit``` will execute it in EOSbox on boot.

#### Desktop entries
Use ```eosbox-desktop``` to install desktop entries in chroot to host (installed to ```~/.local/share/applications/eosbox```), you'll need to add ```sudo``` (or ```doas```) rules to launch eosbox without a password.
#### Lauching apps via rofi
Instead of opening terminal or installing desktop entries everytime you want to run application inside chroot, you may want to launch rofi inside chroot, install rofi and do :
```
eosbox rofi -show drun
```
Just like desktop entries, you'll need to add ```sudo``` (or ```doas```) rules to launch eosbox without a password.
#### Prompt
If you use bash with nerd font you could add a nice little EndeavourOS icon in your prompt, add :
```
[[ -e /etc/arch-release ]] && export PS1=" $PS1"
```
to your ```~/.bashrc```
#### Adding environment variables
Edit ENV_VAR in ```/etc/eosbox.conf```. For example, if you want to use qt5ct as Qt5 theme, edit it like this :
```
ENV_VAR="QT_QPA_PLATFORMTHEME=qt5ct"
```
An example with multiple environment variables.
```
ENV_VAR="QT_QPA_PLATFORMTHEME=qt5ct"
```

#### Adding more shared directories
Edit SHARED_FOLDER in ```/etc/eosbox.conf```. For example: 
```
SHARED_FOLDER=( /home /var/www )
```
Note that this will recursively mount directories.
### Known issues
#### NixOS-specific issues
##### /run mounting
Mounting ```/run``` somehow breaks NixOS, set ```MOUNT_RUN``` in ```/etc/eosbox.conf``` to anything other than ```yes``` to disable mounting ```/run```, then do :
```
eosbox --mount-runtime-only
```
after user login to make XDG runtime directory accessible to chroot enviroment. make sure dbus unix:path is in XDG runtime directory too.
```
$ echo $XDG_RUNTIME_DIR
/run/user/1000
$ echo $DBUS_SESSION_BUS_ADDRESS
unix:path=/run/user/1000/bus
```
Or alternatively if you use WM-only, just disable mounting ```/run``` entirely and manually set XDG_RUNTIME_DIR into ```/tmp``` like ```/tmp/$(whoami)```, this is not recommended if you use systemd, stuffs like Pipewire, Desktop portal, etc may broke.

##### EOSbox didn't access resources in /usr/share
In EOSbox, Symlink ```/usr``` to ```/run/current-system/sw```:
```
sudo mkdir -p /run/current-system/
sudo ln -s /usr /run/current-system/sw
```
make sure /run isn't mounted.

#### PulseAudio refused to connect
This can be caused by different dbus machine-id between chroot and host, copying ```/etc/machine-id``` from host to chroot should do the job.
#### Musl-based distros
Although /run is mounted in chroot environment on boot, XDG_RUNTIME_DIR is not visible in chroot environment, remounting /run will make it visible. do :
```
eosbox --remount-run
```
after user login, Also if you use Void Musl, you need to kill every process that runs in XDG_RUNTIME_DIR when you log out, You need to reinstall eosbox with ```--exp``` flag and use ```startx-killxdg``` instead of ```startx```, or run :
```
/usr/local/share/eosbox/bin/remount_run killxdg
```
on logout. you can put it in ```/etc/gdm/PostSession/Default``` if you use GDM

Tested in Void Linux musl and Alpine Linux.

#### Polkit
```pkexec``` is kind of tricky to make it work in chroot, if you use rofi to launch GUI applications in chroot, you may not able to launch any ```.desktop``` files with ```Exec=pkexec...``` in it. If you really want them to work, you can do :
```
sudo ln -sf /usr/bin/sudo /usr/bin/pkexec
```
in chroot and prevent pacman from restoring ```/usr/bin/pkexec``` by editing ```NoExtract``` in ```/etc/pacman.conf```.

#### No sudo password in chroot by default.
You could use ```sudo``` in eosbox, but you'll have no way to enter the password when doing e.g. ```eosbox sudo pacman -Syu```. also you could enter the password if you do ```eosbox -e < <(echo $COMMAND)```, but that would disable stdin entirely during $COMMAND.
#### Screenshot
![ScreenShot](https://github.com/specialworld83/eosbox/blob/main/screenshot/neofetch.png)
![ScreenShot](https://github.com/specialworld83/eosbox/blob/main/screenshot/yay.png)
![ScreenShot](https://github.com/specialworld83/eosbox/blob/main/screenshot/build.png)
![ScreenShot](https://github.com/specialworld83/eosbox/blob/main/screenshot/fedora_release.png)
