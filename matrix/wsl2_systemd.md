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

安装systemd

```sh
git clone https://github.com/DamionGans/ubuntu-wsl2-systemd-script.git
cd ubuntu-wsl2-systemd-script/
bash ubuntu-wsl2-systemd-script.sh
```

重启wsl，并执行以下命令确认

```sh
systemctl
```

## 错误

报错

```sh
nsenter: 打不开 /proc/28/ns/time: 没有那个文件或目录

```

解决方案

ref [nsenter: cannot open /proc/320/ns/time: No such file or directory #36](https://github.com/DamionGans/ubuntu-wsl2-systemd-script/issues/36)

```sh
TL;DR: Change options of nsenter from -a to -m -p

Thank you @eternalphane for the information, but this could be confusing for some people.

Based on that data, this is how to fix it:

Replace (copy and paste) the following lines of enter-systemd-namespace file. You can do it on Windows side.
USER_HOME="$(getent passwd | awk -F: '$1=="'"$SUDO_USER"'" {print $6}')"
if [ -n "$SYSTEMD_PID" ] && [ "$SYSTEMD_PID" != "1" ]; then
    if [ -n "$1" ] && [ "$1" != "bash --login" ] && [ "$1" != "/bin/bash --login" ]; then
        exec /usr/bin/nsenter -t "$SYSTEMD_PID" -m -p \
            /usr/bin/sudo -H -u "$SUDO_USER" \
            /bin/bash -c 'set -a; [ -f "$HOME/.systemd-env" ] && source "$HOME/.systemd-env"; set +a; exec bash -c '"$(printf "%q" "$@")"
    else
        exec /usr/bin/nsenter -t "$SYSTEMD_PID" -m -p \
            /bin/login -p -f "$SUDO_USER" \
            $([ -f "$USER_HOME/.systemd-env" ] && /bin/cat "$USER_HOME/.systemd-env" | xargs printf ' %q')
    fi
    echo "Existential crisis"
    exit 1
fi
Get inside the broken Linux distribution:
> wsl bash --norc
Reinstall it:
$ bash ubuntu-wsl2-systemd-script.sh --force
Worked on:
WSL2 + Ubuntu-20.10
```