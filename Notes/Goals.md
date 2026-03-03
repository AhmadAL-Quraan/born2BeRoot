

* What is file systems on Linux ext4, xfs, ...
* Revision of Disk partitioning and LVM.
* How does the booting process happened (Boot flow).
```bash
BIOS  
↓  
Reads GRUB code from vda1  
↓  
GRUB loads files from /boot  
↓  
Kernel loads  
↓  
System starts
```
- vda1 = tiny bootloader space
- /boot = actual boot files

![[boot-efi.png]]


# What is BIOS and UEFI ?

* B