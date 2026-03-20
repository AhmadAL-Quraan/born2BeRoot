
```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

# Phrases

* Bootloader: GRUB
* Partition table: GPT or MBR
* Firmaware: UEFI or BIOS


## Boot Process Phrases

- Firmware → BIOS / UEFI
- Bootloader → GRUB
- Kernel → Linux kernel
- Initramfs → Early userspace
- Root filesystem → `/`
- Runlevel / Target → system state
- Secure Boot → Firmware security feature


## Disk & Partitioning

- Disk → `/dev/sda`, `/dev/vda`    
- Partition → `/dev/sda1`
- Filesystem → ext4 / xfs
- Mount point → `/home`
- Swap → Virtual memory (DISK)
- Block device → Disk abstraction
- UUID → Unique identifier for partitions    


## LVM (Very Important for Born2BeRoot)

- PV → Physical Volume    
- VG → Volume Group
- LV → Logical Volume
- PE → Physical Extent
- LUKS → Linux encryption system

Memory trick:
Disk → Partition → PV → VG → LV → Filesystem → Mount


## Encryption

- LUKS → Disk encryption standard    
- dm-crypt → Kernel encryption layer
- Passphrase → Unlock key
- Mapper device → `/dev/mapper/...`

## Filesystem Structure

- `/boot` → Kernel + GRUB files
- `/boot/efi` → EFI partition
- `/home` → User files
- `/etc` → System configuration
- `/var` → Logs & variable data
- `/usr` → Programs
- `/dev` → Devices


## Boot Modes

- Legacy Mode → BIOS    
- UEFI Mode → Modern firmware
- CSM → Compatibility Support Module
- MBR → Old partition table
- GPT → Modern partition table


## System Inspection Commands

- `lsblk` → Show block devices    
- `blkid` → Show UUIDs
- `df -h` → Disk usage
- `mount` → Mounted filesystems
- `efibootmgr` → UEFI boot entries


## Virtualization Terms (Since You Use VMs)

- Hypervisor → Virtual machine manager    
- Guest OS → Installed OS
- Host OS → Your real OS
- Virtual disk → `.vdi`, `.qcow2`
- BIOS/UEFI setting → VM firmware mode


## Advanced (Good for Interviews)

- Boot sector    
- MBR sector (first 512 bytes)
- Stage 1 / Stage 2 bootloader
- Init system → systemd
- Target → multi-user.target
- Chroot → Change root environment

---





# Ultimate Boot Chain Phrase

Memorize this:
```
Power On  
 → Firmware (BIOS/UEFI)  
 → Bootloader (GRUB)  
 → Kernel  
 → Initramfs  
 → systemd  
 → Userspace
```

If you understand that chain, you understand Linux booting.





---

# Firmware 

* `BIOS` or `UEFI` is responsible for starting bootloader ->GRUB.

## BIOS

* Basic input/ output system.
* It the **old firmware** used .
* Firmware = software stored on the motherboard.
* Needs BIOS boot partition (2MB).
* It needs GRUB.
* Loads bootloader from MBR sector.
* Process when turn your computer:
```bash
1️⃣ BIOS starts
2️⃣ It checks hardware (RAM, CPU, disk)
3️⃣ It looks for bootloader on disk (MBR)
4️⃣ It loads GRUB
5️⃣ GRUB loads Linux
```

### BIOS characteristics:

- Very old (1980s technology)
- Uses **MBR** partition table
- Limited to disks ≤ 2TB
- Slower and less flexible



---



## UEFI

* EFI = Extensible firmware interface.
* Moder version = UEFI (Unified Exten...)
* Uses **GPT** partition table.
* Needs EFI partition (~600MB) --> /boot/efi
* Doesn't need GRUB.
* Loads .efi file from partition
* Process when turn your computer:
```bash
1️⃣ UEFI starts
2️⃣ It reads a special partition (EFI System Partition)
3️⃣ It loads a .efi bootloader file
4️⃣ That loads Linux
```

### What Is the EFI Partition?

If you use UEFI, you get:
`/boot/efi`
This is:
- FAT32 filesystem
- ~100–600 MB
- Contains `.efi` boot files



```
1️⃣ Power On
2️⃣ UEFI firmware
3️⃣ Boot Order (decides which bootloader to start)
4️⃣ GRUB (if Debian entry is first)
5️⃣ Linux Kernel
6️⃣ init (systemd)
7️⃣ Userspace (login manager / tty)
```


---




## Major difference 

| BIOS                             | UEFI                                  |
| -------------------------------- | ------------------------------------- |
| Old                              | Modern                                |
| Uses MBR                         | Uses GPT                              |
| Loads bootloader from MBR sector | Loads .efi file from partition        |
| Needs BIOS boot partition (2MB)  | Needs EFI partition (~600MB)          |
| Limited features                 | Supports Secure Boot, networking, GUI |

---

## Questions ?

1) **If `UEFI` already calling `GRUB` file to tell it which OS to run, then how `UEFI` or `BIOS` know where does `/boot/efi` existed on disk (which have grub file) in Linux file system ?**

	* UEFI does NOT understand Linux paths like `/boot/efi`.
	* UEFI does this:
		1. Looks for a special partition called: > **EFI System Partition (ESP)**
		2. That partition:
		    - Has a special GPT type
		    - Is formatted as FAT32
		3. UEFI reads files directly from that FAT32 partition.
	* No Linux involved yet.
	* When UEFI boots:
		1) It loads `EFI\debian\grubx64.efi`
		2) That GRUB binary then:
			- Reads your real Linux partitions
			- Loads `/boot/grub/grub.cfg`
			- Loads kernel from `/boot/`
		3) /boot/grub/  has:
			├── grub.cfg  
			├── x86_64-efi/  
			├── fonts/  
			└── themes/



---


# GRUB 

* GRUB: Grand unified bootloader.
* It is the program that loads your operating system.
* It's also called boot manager.
* So it's both boot (manager, loader).





---






# /boot directory

*  It's the standard file where it has:
	1) Linux kernel (vmlinuz).
	2) initramfs: An `initramfs` (initial RAM file system) is a compressed `cpio` archive loaded into RAM by the Linux kernel during boot, acting as a temporary root file system. It provides early userspace tools, drivers, and modules needed to mount the actual root file system (e.g., encrypted, LVM, or networked drives) before transitioning to the real system.
	3) GRUB files.
* It is usually:
	* `etx4` filesystem.
	* Can be its own partition OR part of `/`.

## /boot/efi

* It is EFI system partition (ESP).
* It contains:
	* Bootloader files (`.efi` files).
	* Firmware-readable boot entries.
* It is:
	* FAT32
	* Required for UEFI
	* Mounted at /boot/efi



	
















# Resources

![](https://www.youtube.com/watch?v=EjrAzulPsT4&t=500s)
