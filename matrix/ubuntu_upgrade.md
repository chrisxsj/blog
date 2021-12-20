Ubuntu only provides (and tests) LTS releases for direct download and installation on WSL.

You can install the base "Ubuntu" distribution (which is currently 20.04) and then upgrade it to 21.10 with a slight variation on the normal mechanism:

sudo apt update && sudo apt upgrade to make sure the existing release is up-to-date.

sudo apt remove snapd -- Needed because WSL doesn't support Systemd directly

Sudo edit /etc/update-manager/release-upgrades and change the last line to:

prompt=normal
sudo do-release-upgrade to upgrade to Hirsute/21.04

Recommended: Exit WSL, execute wsl --terminate Ubuntu from PowerShell or CMD, and restart WSL/Ubuntu.

Repeat sudo do-release upgrade to upgrade to Impish/21.10

Recommended: sudo apt purge needrestart to get rid of unnecessary checks after installing any package.

Again, this is not a scenario that Canonical seems to necessarily test, but people have been doing it for a while (as well as installing many other different distributions).

After upgrading, I do recommend creating a backup image. This can be used to create new, clean 21.10 installations in the future if you need to try something out without impacting your normal one.

wsl --export Ubuntu Ubuntu2110_fresh_install.tar
Create new installations from it by creating a directory, and:

wsl --import Ubuntu2110Test <directory> Ubuntu2210_fresh_install.tar
I personally just go ahead and create a new installation automatically. It has the advantage of:

Letting me name the installation what I want (e.g. 'Ubuntu-21.10`)
Placing it somewhere other than under %userprofile%\Local\AppData\Packages


================

Today, when I upgraded an old Ubuntu device from 16.04 to 18.04, I had a problem that prevented the upgrade smoothly.

Checking for a new Ubuntu release Please install all available updates for your release before upgrading
In order to upgrade more smoothly, I checked some online information and recorded solution below in case I forget it. Now I am used Ubuntu 18.04 on the main computer, and I find it very troublesome just because the position of the close window button is different, hahaha.

Solution
First, we need to update our current system.

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade
After performing the above actions, we can proceed to the next step.

sudo do-release-upgrade
But this time usually reminds you that you need to reboot, so let's reboot.

sudo reboot
Upgrade after booting:

sudo do-release-upgrade
At this time, you usually need to wait patiently for a while, and then the system will automatically start updating.