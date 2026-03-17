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


| Requirement             | File                           |
| ----------------------- | ------------------------------ |
| Password expiration     | `/etc/login.defs`              |
| Password complexity     | `/etc/security/pwquality.conf` |
| Password history        | `/etc/pam.d/system-auth`       |
| Authentication system   | PAM                            |
| `Sudoers` configuration | /etc/sudoers                   |



---


## PAM module 

* PAM i.e **Pluggable Authentication Modules** is a **modular system** that separates **authentication logic** from applications.
* It is a Linux framework that manages authentication and password policies through configurable modules used by applications like login, SSH, and passwd.


* This means programs like:
	- `login`
	- `ssh`
	- `su`
	- `passwd`
do **not implement authentication themselves**.  
Instead, they ask **PAM** to handle authentication.


### Why PAM Exists

Before PAM, every program had to implement authentication separately.

PAM allows:
- centralized authentication rules
- flexible security policies
- easy modification without changing applications



### Example

When you run:
`passwd`
The process is:
```bash
passwd command  
      ↓  
PAM modules  
      ↓  
password policy check  
      ↓  
password accepted or rejected
```

So PAM enforces rules like:
- minimum password length
- uppercase letters
- password history
- expiration policies



### PAM Configuration Files

Main directory:
`/etc/pam.d/`

Example files:

| File                     | Purpose                      |
| ------------------------ | ---------------------------- |
| `/etc/pam.d/sshd`        | SSH authentication rules     |
| `/etc/pam.d/login`       | Console login rules          |
| `/etc/pam.d/system-auth` | Common system authentication |
| `/etc/pam.d/passwd`      | Password change rules        |



### PAM Modules

PAM works through **modules**, for example:

| Module             | Purpose                          |
| ------------------ | -------------------------------- |
| `pam_pwquality.so` | password strength rules          |
| `pam_unix.so`      | standard UNIX authentication     |
| `pam_pwhistory.so` | password history                 |
| `pam_faillock.so`  | account lock after failed logins |



---




## Password expiration 

* `/etc/login.defs`

![[password-expiration.png]]

* For acceptable password length and password complexity enforces, we will use PAM module.




---



## Password complexity 

* `/etc/security/pwquality.conf`
![[password-complexity.png]]




---



## Enforcing user and root to comply for password rules by PAM

* If you try as `root` to change the password for any account (including root), it will just warning you that you are not complying with the rules specified by PAM, and not enforcing you as a `root`.

 ![[no-forcing-on-root.png]]

* To solve this we need to enforce that in `/etc/pam.d/system-auth`.
![[pam-system-auth.png]]
* Add on          `password     requisite        pam_pwquality.so -->`:
	* `enforce_for_root` : To force the password quality checks on root too.
	* `local_users_only`: The password quality checks apply **only to local users stored on the system** (in `/etc/passwd`).
	* `retry=3`: How many tries do you have before exit.




---



## Sudo configuration


* Sudo configuration file is in : `/etc/sudoers`
* Shortcut for it using `sudo visudo`

### Changing the number of tries for a user to use sudo.
```bash
# In /etc/suderos add this line:
Defaults passwd_tries=N
```
>[!note] The approach used to change the tries for sudo is differ than the one used for pwquality. Both for different things.


### Changing the **Custom message appears** when fail password entered for sudo.

```bash
Defaults badpass_message="Wrong pass"
```

### Each action using sudo has to be archived and saved in a log file.
```bash
Defaults log_input
Defaults log_output
Defaults iolog_dir="/var/log/sudo" # Example file
```

| Setting      | Meaning                         |
| ------------ | ------------------------------- |
| `log_input`  | logs user keyboard input        |
| `log_output` | logs command output             |
| `iolog_dir`  | directory where logs are stored |


* In `/var/log/sudo` a list of directories and files will be made each time a **user use `sudo`**:
```bash
/var/log/sudo/
├── seq
└── 00
    └── 00
        └── 0A
            ├── log
            ├── log.json
            ├── stdin
            ├── stdout
            ├── stderr
            ├── timing
            ├── ttyin
            └── ttyout
```

| File       | Meaning                    |
| ---------- | -------------------------- |
| `stdin`    | what the user typed        |
| `stdout`   | command output             |
| `stderr`   | errors                     |
| `ttyin`    | terminal input             |
| `ttyout`   | terminal output            |
| `timing`   | replay timing              |
| `log.json` | metadata about the command |
* Now each time a user write something with `sudo`, it gonna be saved in `/var/log/sudo`.
* You can **see the records using** `sudo sudoreplay -d <log directory> <session_id>`
* **List the sessions id** using `sudo sudoreplay -d <log dir> -l`

* Summary:
```bash
sudo command
   ↓
record session
   ↓
store in /var/log/sudo/sessionID
   ↓
replay with sudoreplay
```



### Enable TTY mode


* This mode forces `sudo` to **run only from a real terminal (TTY)**, so `sudo` **will fail if there is no interactive terminal**.
* Example of blocked usage:
	`ssh user@server "sudo ls"`

>It require a valid interactive terminal

* Apply it in `/etc/sudoers` or `sudo visudo`
```bash
Defaults requiertty
```
* Verify it's working:
`sudo sudo -V | grep tty`




### Restrict the paths used by sudo

* In `/etc/sudoers` add:
```bash
Defaults secure_path=...
```


