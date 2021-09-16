# wsl2_systemd

**作者**

Chrisx

**日期**

2021-09-13

**内容**

安装systemd。据说gnome桌面是基于systemd，而WSL不支持systemd，所以需要先安装systemd，ref [ubuntu-wsl2-systemd-script](https://github.com/DamionGans/ubuntu-wsl2-systemd-script)

----

[toc]

## usage

need git

```sh
sudo apt install git

```

Run the script and commands

```sh
git clone https://github.com/DamionGans/ubuntu-wsl2-systemd-script.git
cd ubuntu-wsl2-systemd-script/
bash ubuntu-wsl2-systemd-script.sh
# Enter your password and wait until the script has finished
```

Then restart the Ubuntu shell and try running systemctl

```sh
systemctl
```

## 错误

Cannot execute daemonize to start systemd.

ref [Not working on WSL2 - Ubutnu 20.04 #37](https://github.com/DamionGans/ubuntu-wsl2-systemd-script/issues/37)

Looks like daemonize wasn't found for some reason.

You should be able to log into WSL by typing "wsl -u root" in cmd or powershell.
Check if daemonize is installed by typing "which daemonize".
I assume you'll have no output (I have "/usr/bin/daemonize" for example).
If you do have some output, please post it in a reply.
You can either install daemonize or disable the startup script.

To install daemonize type:
"sudo apt-get install daemonize"
Do note however, that it's quite likely that the other things the script tried to install failed.
You can run the script again in that case. Remember to sudo it.

If you want to disable the systemd start script, do the following:
Enter in "nano /etc/bash.bashrc"
Put a # on the start of the line that says "source /usr/sbin/start-systemd-namespace"
To enable the systemd start script again, simply remove the newly added #