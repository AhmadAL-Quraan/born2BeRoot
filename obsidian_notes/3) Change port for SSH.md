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



![[change-port-diagram.png]]

* To change ssh port or any other service port on the system, you need 3 things:
	1) Change the configuration file for this service (in this case `sshd`) to allow it to listen to any other port from `/etc/ssh/sshd_config`, in this case port 4242 instead of 22 .
	2) Allow packets to access this port on the Linux server throw configuring the firewall manager -> in this case on Rocky Linux or RedHat it's `firewalld`.
	3) Give permission to `sshd` to listen on this port (resource) throw `SELinux`.



## Change the configuration file for sshd service

* In `/etc/ssh/sshd_config`, change the port from 22 to 4242.

 ![[port-4242.png]]


## Configure the Firewalld


### 1) Add the port rule

```bash
sudo firewall-cmd --permanent --add-port=4242/tcp
```
Explanation:
- `--permanent` → rule persists after reboot
- `--add-port=4242/tcp` → **allow TCP traffic on port 4242**
SSH uses **TCP**, so you must specify `tcp`.


### 2) Reload the firewall

Apply the changes:

```bash
sudo firewall-cmd --reload
```


### 3) Verify the rule

Check that the port is allowed:

```bash
sudo firewall-cmd --list-ports
```
--> Output: `4242/tcp`



## Allow sshd to listen on port 4242 using SELinux


* `semanage port -a -t ssh_port_t -p tcp 4242`

| Part            | Meaning                                                                           |
| --------------- | --------------------------------------------------------------------------------- |
| `semanage`      | SELinux management tool used to modify policies                                   |
| `port`          | Indicates we are modifying **port rules**                                         |
| `-a`            | **Add** a new rule                                                                |
| `-t ssh_port_t` | Assign the port to the **SSH SELinux type** --> see port type `semanage port -l ` |
| `-p tcp`        | Specify the **protocol (TCP)**                                                    |
| `4242`          | The port number we allow for SSH                                                  |