

## Tasks

*  The hostname of your virtual machine must be your login ending with 42 (e.g., wil42).
You will have to modify this hostname during your review.
* You have to implement a strong password policy.
* You have to install and configure sudo following strict rules.
* In addition to the root user, a user with your login as username has to be present.
* This user has to belong to the user42 and sudo groups.
*  you have to create a simple script called **monitoring.sh**. It must be developed in
bash.



>[!note] Details about each task in the .pdf sheet + questions under


## Hostaname

* How to change hostname ?
## SSH

* ***What is SSH?**
	* SSH: i.e secure shell it's a **network protocol**, set of rules that defines how communication over the network between two devices should happen over the public network.
* **How does SSH works ?**
	* SSH works using a client-server model. The client connects to the SSH server, performs a key exchange to establish encrypted communication, then authenticates the user using a password or SSH keys. After authentication, a secure remote shell session is created.
* **How can you check SSH service status?**
	1) Install openSSH `dnf install openssh`.
	2) Check `systemctl status sshd`
* **How to restart SSH service?**
	* `systemctl restart sshd`
*  **Where is SSH configuration file?**
	* `/etc/sshd_config`
* **Difference between SSH client and SSH server**
	* SSH client: initiate the connection.
	* SSH server: Accepting incoming ssh connection.
* **How to change the SSH port to 4242 on Rocky Linux and why ?**
	* Change configuration file for ssh to allow it to listen on port 4242.
	* Allow traffic on 4242/tcp using firewalld.
	* Give permission for ssh_port to listen on 4242 using SELinux -> Controls which process to access what resource on the system.
* **How do you check that port 4242 is open?**
	* `ss -tuln` -> socket statistics 
		* `-t`: `TCP` socket
		* `-u`: `UDP` socket 
		* `-l`: listening sockets.
		* `-n`: numeric
* How to generate public, private key ?
	* `ssh-keygen`
* Difference between public and private key?
	* `public key`: The key exists on server.
	* `privat key`: Key used to decrypt the public key.
* Why is key authentication safer than password ?
* What is `authorized_keys`?  
* How to copy ssh-key to server to allow authorized connection only ?
* Why is SSH root login disabled?
* How to disable root SSH login?



## Users and groups

* How to make a user ?
* How to make a group ? 
* How to add a user to a group ?



## System information script

* How to make the script run on specific time ?
* How to make a message appears on all terminals sessions ?
* How to see what current sessions are opened on the system and users ?