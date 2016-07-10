Getting started
=====
I've been testing this out on Ubuntu 16.04 x64 and a VMware VM configured to 
boot from UEFI. YMMV when using it on different platforms. I don't plan on 
adding support for a bunch of platforms, but welcome any contributions that
provide such support.

Environemnt
=====
*VMWare VM with Ubuntu 16.04 x64 installed, with build-essentials also
 installed (sudo apt-get install build-essentials)
*VMWare VM with a minimal disk (mine is around 3GB) for the UEFI environment

UEFI VM
-----
Boot a fresh VM with the gparted live CD, and choose the command line
interface. Once on the command line, run gparted against the block device
on the system:
```
gdisk /dev/sda
```
You'll want to create a GUID partition table, using the `o` option. After the
GPT is created, you'll add a new partition, using `n`. The size defaults are
fine, and the partition type will be ef00 for EFI. Write the changes to disk
with `w` and shutdown.

Remove the GParted live CD from the VM, and open up the VM's configuration
file in a text editor:
```
vim UEFI.vmx
```
Find the firmware="bios" entry if it exists, and replace bios with efi. If it
doesn't exist, add the line:
```
...
firmware="efi"
...
```
Boot the VM and wait for the other boot options to time out. You will be given
a text based menu, and select the UEFI shell option. Once it's booted to the
shell, change to the newly created disk, and create a directory:
```
Shell> fs0:
fs0> mkdir EFI
```
Once again, shutdown the VM.

Now attach the UEFI disk to your Ubuntu VM as a secondary disk, so we can build
within the Ubuntu VM, copy the build product onto the mounted UEFI disk, and
then test on the UEFI VM. After a copy, run sync a few times to make sure any
of VMware's disk caching isn't holding on to the writes. You can then suspend
your Ubuntu VM and boot the UEFI VM, get to the shell again via the text menu,
and attempt to run your application:
```
Shell> fs0:
fs0:> cd EFI
fs0:EFI> test
Hello, World!
fs0:EFI>
```
