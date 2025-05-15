# Debian Setup


## Introduction


## Debian Headless / Base Install

The `headless.sh` script setup the Debian system with base applications and configuration for an headless system.

### Install Headless System

```bash
wget -q -O - https://github.com/ubiozur/debian-setup/releases/latest/download/headless.sh | bash
```

### What It Does

1. Update the system
2. Setup Grub for faster boot time
3. Install base CLI Applications
4. Install dotfiles and setup an cronjob to auto update them.
5. Setup the TTY font
6. (Optional) Reboot the system


## Debian Testing Repositories

The `testing.sh` script setup the Debian system to use the current named testing repository (version name like `trixie`, and not just `testing`) as well as upgrade the system to it.

It will allow `main` `contrib` `non-free` `non-free-firmware`.

### Install Testing Repositories

```bash
wget -q -O - https://github.com/ubiozur/debian-setup/releases/latest/download/testing.sh | bash
```

### What It Does

1. Create '*modern*' Deb822 Source file `/etc/apt/sources.list.d/Debian.sources`
2. Delete (Backup) if it exist `/etc/apt/sources.list`
3. Upgrade the distribution
4. Clean unused dependencies
5. (Optional) Reboot the system

> [!TIP]
> You can switch your source file to Deb822 format using the command `sudo apt modernize-sources`

## Usage

```
Usage: ./script.sh [OPTIONS] ...

Options:
  -d, --debug         Enable debug and verbose output.
  -v, --verbose       Enable verbose output.

  -h, --help          Show this help message and exit.
```

* `-d, --debug` Display the output as Debug (no clearing the screen, no hiding commands output), do not clean the temporary files at exit.
* `-v, --verbose` Display more verbose output for the script

## VM Dev Setup

**Make snapshot of the VM Often!**

* Create a debian VM with minimal install
* Make sure `Memory -> Enable shared memory` is checked.
* `Add Hardware -> Filesystem -> virtiofs` Source path is the path of the folder to share on from the host, Target path is `debian-setup`
* Fully reboot the VM
* Create a file `mount-debian-setup.sh` with the following script inside

```bash
#!/usr/bin/env bash

mkdir -p "${HOME}/debian-setup"
sudo mount -t virtiofs debian-setup "${HOME}/debian-setup"
```

* Make file executable `chmod u+x "${HOME}/mount-debian-setup.sh"`
* Run the file `./mount-debian-setup.sh`
