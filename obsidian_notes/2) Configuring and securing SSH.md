

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



---






# What is SSH ?

* SSH itself is just a **protocol (set of rules)**, it's an **application protocol** that describes how secure communication should work.
* It is an **application-layer protocol** that runs over TCP and provides secure remote access and encrypted communication services.


* It defines:
	1) Key exchange
	2) Encryption
	3) Authentication
	4) Message formats
	5) Session management.
	
* All on top of TCP (port 22)
>[!info] SSH itself is not software, it's a standard protocol.

```arduino
TCP/IP model 

Application   -> SSH, HTTP, FTP, rsync
Transport     -> TCP
Internet      -> IP
Link          -> Ethernet / Wi-Fi
```

```pgsql
OSI model:

Layer 7 – Application   -> SSH
Layer 6 – Presentation -> Encryption, compression (handled by SSH)
Layer 5 – Session      -> Session management (handled by SSH)
Layer 4 – Transport    -> TCP
Layer 3 – Network      -> IP
```

* So in short, SSH doesn't:
	1) Creates a new network layer.
	2) It does not replace TCP/IP.


* Example using rsync:

```ssh
rsync (application) -> SSH (application – encryption & auth) -> TCP (reliable transport) -> IP (routing)
```



---




# What is OpenSSH ?


 * It's an open-source implementation of the SSH (secure shell) protocol (actual code), which allows us to securely connect and communicate to a remote computers over an **insecure network**.
 * Think of OpenSSH as something that acts on those rules which they are the SSH rules themselves.
 * Written mainly in C, by OpenBSD team.
 *  **On a public network, SSH creates an encrypted connection (tunnel) that allows data to be sent and received securely.**

| Concept        | Example                     |
| -------------- | --------------------------- |
| Protocol       | Traffic laws                |
| Implementation | Cars that follow those laws |


## What OpenSSH provide ?

| Program       | What it is                   |
| ------------- | ---------------------------- |
| `ssh`         | Client program               |
| `sshd`        | Server daemon                |
| `scp`         | Secure copy tool             |
| `sftp`        | Secure file transfer         |
| `ssh-keygen`  | Key generator                |
| `ssh-agent`   | Key manager                  |
| `ssh-copy-id` | Install public key on server |


## What OpenSSH is used for ?

1) Secure remote login:
```bash
	ssh user@server_ip
```
* It's a replacement for telnet or rlogin.
>[!info]  ==telnet and Rlogin== are ==older network protocols for logging into and controlling remote computers==, acting as a text-based "window" to another machine, but both are **highly insecure**, sending data (including passwords) in plaintext.
	
2) Secure file transfer:
```bash
scp file.txt user@server:/path/
```
or sync directories:
```bash
rsync -avz foler/ user@server:/path/
```
> [!info]  -a is short for archive, means sync the directories as they are, -v verbose (details), -z to compress the dir.


3) Key-based authentication (passwordless login)

```bash
ssh-keygen
ssh-copy-id user@server
```

4) Port forwarding (SSH tunneling)

Expose or protect services securely:
```bash
ssh -L 8080:localhost:80 user@server
```

Very useful for:
- Databases
- Web apps
- Remote debugging




---


# Using command line with SSH


* We can ssh using:
```bash
ssh remotehost
```
* Now the remote-host should be the IP address of that host.
* host-names in general they are a human readable texts, but when we want to connect, the network needs a numeric address (IP) to know where to send packets.

```bash
ssh username@remote-host
```
* Now if we want to connect to a specific username on that remote host, we can use the above command.


```bash
ssh username@remote-host ls #THis will list files when you enter the password
```
* Also we can send commands directly when connecting throw ssh (it needs password approval).

>[!info] Solving problems on [overTheWire](https://overthewire.org/wargames/bandit/bandit19.html) is useful to understand more


## Identifying remote users

* The `w` command is very important which used to displays a list of users currently logged into the computer (either physical or throw ssh).

* It shows:
	1) user name
	2) TTY (pusedo terminal)
	3) FROM (IP address if it was ssh)
	4) LOGIN@ (what time)
	5) IDLE (you didn't run any commands for some times)
	6) What --> shows the command or activity the user currently running.


## Making .ssh file for new users

* When making a new `.ssh` file for new users, we must do 3 things:
	1) chmod the .ssh directory into 700
	2) Making `authorized_keys` file in `~/.ssh/` and `chmod 600` for it.
	3) `chown` for `~/.ssh/authorized_file` into the user who made it.


>[!note] `authorized_keys` tells the SSH server **which public keys are allowed to log into a specific user account**. So when you do `ssh-copy-id`, the public key copied to this file.



---


# SSH host keys

* What happened when a user uses SSH to connect to a server? 
	* The `ssh` command checks to see if it has a copy of the public key for that server it tries to connect to in:
			`/etc/ssh/ssh_known_hosts(sysetm wide)` or `~/.ssh/known_hosts (per user)`
	* If the server's key exists but changes, SSH will refuse to connect:
		* You may ask, how it will knows that the public host key, changed ?
			* This is because the `known_host` file saves in this format `hostname/ IP --> public host key`.
			* So it knows that this hostname "example.com" --> have this IP, so if it changed means something wrong and we shouldn't connect to it until changed manually from the known_host file.
	* If it didn't found it, it will ask your confirmation to continue the connection, and the server public key will be saved in the known_host file.
	



### What inside `known_host` file:

![[known-host-file.png]]
* First field: hostname --> sometimes you will find it hashed for security reasons.
* Second: encryption algorithm for the key
* Third: The key itself.


>[!note] Each remote SSH server that you connect to stores the public key in `/etc/ssh/` or in `~/.ssh/`with the extension `.pub` 






---


# SSH key-based authentication



* Now we can configure a server to authenticate without a password and just with the public-private key.
* The public key is given to the server and the private key is saved in the place where you want to access that server, and it must kept secure (The private key).





## 1) Generating SSH keys


* We can use `ssh-keygen` command to make a private and public key, private keys are saved as `~/.ssh/id_rsa`, and public as `~/.ssh/id_rsa.pub` by default ( until you change there name).
* There is a very important concept here, what happened when you connect using SSH:
	1) The private file is encrypted, so SSH cannot use it unless it decrypts it.
	2) To decrypt it we need to use the passphrase (password).
	3) Something must provide the passphrase:
		a) Now you can't store the private key unencrypted -> this is bad and your identity may be stolen.
		b) Store the passphrase somewhere, (bad) you can't just save the passphrase anywhere.
		c) Give it (save it) in the memory using the `ssh-agent`:
		* It's a background process that:
			1) Holds decrypted private keys in memory (RAM) --> Caching it in memory
			2) Never writes them to disk.
		* You unlock your key once (write the passphrase) using `ssh-add` like `ssh-add ~/.ssh/id_rsa` 
			After that:
			- The agent keeps the decrypted key in RAM
			- SSH can use it **without asking for the passphrase again**

![[ssh-keygen.png]]

>[!note] if the `ssh-agent` didn't work on your system automatically (by the daemon), you can run it using `eval $(ssh-agent)` -> it will give you `Agent pid ****`


>[!note] The `eval` command set automatically the variables asked by the agent so you don't have to, it also displays the PID of the `ssh-agen` process.


###  SSH key lookup order  

When you run:
```bash
ssh user@host
```


1) SSH first loads configuration from:
- `/etc/ssh/ssh_config`
- `~/.ssh/config`

2) **Ask `ssh-agent`**:
    If an **ssh-agent** is running and SSH is allowed to use it, SSH will:
	1. Ask the agent for available keys.
	2. Try those keys with the server.

	Important details:
	- The **private keys stay inside the agent**
	- SSH only asks the agent to **sign a challenge**
	- The keys are already **decrypted in memory**
	
 **If not found in the agent**:
    - SSH searches for private key files in:
 ```bash
 ~/.ssh/id_rsa  
~/.ssh/id_ecdsa  
~/.ssh/id_ecdsa_sk  
~/.ssh/id_ed25519  
~/.ssh/id_ed25519_sk  
~/.ssh/id_dsa (deprecated)
 ```
- If a key is found:
        - SSH asks you for the **passphrase**            
        - Decrypts the key
        - Uses it for authentication
- **If nothing works**:
    - SSH falls back to password authentication (if allowed)



3) SSH may try keys from `IdentityFile`

If `~/.ssh/config` contains:
```bash
Host github.com  
    IdentityFile ~/.ssh/github_key
```
Then SSH will **try that key before default keys**.

>[!info]  If you don't have your private key in the ssh-agent, you may get a message says **Make sure you have the right authentication** . This is because sometimes ssh doesn't check the disk at all. --> Make sure you always have your `ssh-agent` running to solve this. 




## 2) Sharing the public key

* We can share the public key with the meaning server by using `ssh-copy-id` command:
```bash
ssh-copy-id -i <Public-key_file_path> user@remote-host
```

![[ssh-copy-id.png]]
* `-i` to identify the file named `.ssh/key...`

* Now when we want to **sign in** using the private key:
![[ssh-connection-key.png]]
* `-i`: to identify the file having the private key.




---

# Customizing OpenSSH service configuration


* OpenSSH is provided by a daemon called sshd, it's main configuration file is in `/etc/ssh/sshd_config`.
* We can edit it to increase the security of our system:
	1) Prohibit direct remote login to the root account.
	2) Prohibit password-based authentication (Replaced by private-public key).


## Prohibit access to the root

* In this file path `/etc/ssh/sshd_config` is you search for `PermitRootLogin` you can set it to `no` ---> so you prohibit users from accessing the system as root.

![[permit-root-login.png]]

* Then reload `systemctl reload sshd` --> telling sshd to re-read it's configuration.

## Prohibit using password-based auth

* To increase the security and just allows those who have the private key to access our server, we can set disable using of password.
* In the same configuration file, search for `PasswordAuthentication` and set it to `no` --> default value is `yes`
![[password-auth.png]]







---







# Resources

* [overTheWire](https://overthewire.org/wargames/bandit/bandit19.html) --> I encourage you to try these war games challenges, it's CTF like challenges but in more learning curve way, it teaches a lot about Linux, SSH and a lot more...
* [Wikipedia](https://en.wikipedia.org/wiki/Secure_Shell) --> good explanation.
* Of-course  RHSA 1 book version 8.0
* [OpenSSH man page](https://www.openssh.org/manual.html)
* [DigitalOcean website](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys) 