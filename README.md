# Set up a server 
* Set up a Rocky Linux server with best security practices.
* I have chosen **Rocky** Linux over **Debian** for this task because while both of them are stable, but Rocky is enterprise-grade distribution compatible with RHEL. It enforces stricter security defaults compared to Debian, which makes it more suitable for learning system administration and security practices, and honstly it's more used in the industry.
* Debian is easier and more flexible, but Rocky provides a more realistic server environment and stricter behavior, which is better for learning advanced Linux concepts.

## Comparing Debian vs Rocky
| Feature            | Debian          | Rocky Linux            |
|--------------------|-----------------|------------------------|
| Stability          | Very stable     | Enterprise-grade stable |
| Ease of use        | Easier          | Slightly stricter      |
| Security defaults  | Moderate        | Stricter               |
| Industry usage     | Common          | Widely used in servers |
| Learning sysadmin  | Good            | Excellent              |



# Notes 

* I have made notes about each concept related to the task as pdf's (easier to manipulate images) in Notes.

# Topics I improved in

* Booting: How Linux boot from firmware (UEFI, BIOS) -> boot loader -> kernel -> initrmfs -> drivers ....

* Password policies and security: I didn't know much about password policies control in Linux, I knew how to make password aging (expire after x days), but (!you must enter a capital letter or small ..), using **PAM policies** -> **/etc/pwqaulity**, **/etc/pam.d/system-auth**

* SSH: I wrote a whole pdf about **ssh**, I covered a lot of aspects from it.

* SELinx: A lot of aspects about it and how it uses MAC (Mandtory access control) to specify what process to access which resources.

* Network: OSI model, TCP/IP model, commands like `ip` to have informations about network interface(MAC address), Public IP address, private IP address, route table.
