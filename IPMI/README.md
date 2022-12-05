# IPMI

[![asciicast](https://asciinema.org/a/Q8MdmuaVdCGALs3N1Rdui2Xc7.svg)](https://asciinema.org/a/Q8MdmuaVdCGALs3N1Rdui2Xc7)

Want to manage your node using a registry? Let's try it the IPMI way!

For this, ill be using a PiKVM. Though any host capable of serving a .img to your IPMI is usable. This example just takes advantage of USB emulation and the IPMI having a CLI for UOR to run.


## !!! Warning !!!

To allow CRI-O to run containers on this filesystem, this example **zaps the first available disk**. Have a free NVMe/SATA device or have it prepared to go away! You've been warned.

## 0. Follow along and adjust any values! 
These would be 
- Your kubeadm tokens for airrootfs/etc/kubeadm/kubeadm.conf
- Any registry mirrors in airrootfs/etc/containers/registries.conf
- Dataset queries used by the image. _(You may be able to pass a query arg from a kernel command line arg to the query ran in airootfs/root/init.sh)_

## 1. Build your image

` sudo podman run --privileged -v .:/profile ghcr.io/uor-framework/examples/archiso:latest mkarchiso -v -w /tmp -o /profile/out /profile`

If you're following on from our last OS demo, you may notice this image is a bit smaller! This is because we're using only the necessary packages for our node.

## 2. Mount the image

We'll be mounting its contents so UOR can read it.

`sudo mount -o loop /full/path/to/out/archlinux-baseline-date.iso /mnt/iso`

## 2.5. Let's explore this for a moment

```sh
[sam@sampc iso]$ tree
.
├── arch
│   ├── boot
│   │   ├── amd-ucode.img
│   │   ├── licenses
│   │   │   └── amd-ucode
│   │   │       └── LICENSE.amd-ucode
│   │   └── x86_64
│   │       ├── initramfs-linux-hardened-fallback.img
│   │       ├── initramfs-linux-hardened.img
│   │       └── vmlinuz-linux-hardened
│   ├── grubenv
│   ├── pkglist.x86_64.txt
│   ├── version
│   └── x86_64
│       ├── airootfs.erofs
│       └── airootfs.sha512
├── EFI
│   └── BOOT
│       ├── BOOTIA32.EFI
│       ├── BOOTx64.EFI
│       └── grub.cfg
└── syslinux
    ├── boot.cat
    ├── cat.c32
    ├── etc for syslinux..
```

We've got the whole filesystem build in the `airootfs.erofs` image, some bootable information for EFI/BIOS, and...that's about it. 
_Soon_ UOR will be able to map symlinks. This will give us a _full_ **S**oftware **B**ill **o**f **M**aterials. Until then, we're working around this by taking advantage of the compressed root filesystem. 

This gives us some creativity! We can make images for different bootable systems based on _who_ is asking. For now, we're going to take the whole collection and push it up.

## 3. Push the contents

Again, we'll use our trusty local go registry for this.
```sh
uor build collection uor go.registry:1338/test:latest --dsconfig dataset-config.yaml
uor push go.registry:1338/test:latest --insecure --plain-http
```

## 4. Setup IPMI

Here is where our paths diverge. 

There are many types of IPMI interfaces. And while there are consistent tools such as redfish and ipmitool, we will need a spot to ssh and pull down our virtual media using uor.

For example, if you ssh into your IPMI server now, you may see something like this.

```sh
                        >> SMASHLITE Scorpio Console <<

->help
COMMAND COMPLETED : help

Command Name: help
Used to get help on commands and targets

Usage: help [-options]

Options:
         examine - used to examine the command (bypasses executer)
         help - shows help on how to use help
         output - formats the output string (should be used with format (text,clpcsv,keyword,clpxml)
                                 like help -output format=keyword 
         version - shows the smash version

->
```

Gigabyte and Asrock Rack use SMASHLITE Scorpio Console for their ssh sessions. Though we'll use something different here. A PiKVM. But don't worry! You can follow along with a generic workstation, VM, or server box that will act as the host for these images. Let's get started.

This allows us to download UOR, and mount virtual media! 


## 5. Create a virtual image

_For PiKVM, enable an extra drive and reboot first https://docs.pikvm.org/msd/#how-to-enable-extra-drives_

We just need a blank one we can set up and mount. We'll treat this like any other USB in a moment.

```sh
dd if=/dev/zero of=/srv/uor/flash.img bs=1M count=1000 status=progress
```

For this example and for simplicity, we'll keep our focus on EFI.

Apply a loopback to the new flash image so it appears as a device.
```sh
losetup /dev/loop0 /srv/uor/flash.img
```

Create a partition on the device using your favorite part managed `fdisk` or `gdisk` for example. 

```sh
fdisk /dev/loop0
```

After you're done, run a probe on it to get the latest information on the loopback device.

```sh
partprobe /dev/loop0
```

Create a fat filesystem on the new loopback device

```sh
mkfs.fat -F 32 /dev/loop0p1
fatlabel /dev/loop0p1 ARCH_202211 #change the date to reflect the current date of the build
```

Mount it!

```sh
mount /dev/loop0p1 /mnt/usb
```

And pull the contents from the registry into our virtual USB!
```sh
uor pull go.registry:1338/archiso:latest --attributes=q-default.yaml --insecure --plai
n-http -o /mnt/usb/
```

## 6. Share it!

We now have our virtual image ready to go at /srv/uor/flash.img. IPMI consoles based on server boards from American Megatrends typically have a way to mount an image from here if you host it via http or nfs. 

For PiKVM, run `kvmd-otgmsd -i 1 --set-rw=0 --set-cdrom=0 --set-image=/srv/uor/flash.img` to attach the image to your connected host. Note: it's read only as we have it actively mounted as a loopback device on our host. Though we don't need RW since we're booting an ephemeral system. 

## 7. Boot it! 

You're ready to go! Watch your node automatically boot into an ephemeral filesystem and join your cluster!