#!/bin/bash

exec 2>/dev/null
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"
BOLD="\e[1m"

#General info
echo -e "==General info=="

echo -e "${RED}Current user:${RESET} $(whoami)"
chasis=$(hostnamectl | sed -n 's/^[[:space:]]*Chassis:[[:space:]]*//p')
#Move until true in sed (regex)
os_name=$(cat /etc/os-release | grep -i pretty | sed 's/[^"]*//; s/"//g')
echo -e "${RED}Distro name:${RESET} ${os_name}"
shell=${SHELL}
echo -e "${RED}Shell:${RESET} ${shell##*/}"
echo -e "${RED}Chassis: ${RESET}${chasis} -> ${BLUE}\"Chassis\" refers to the physical or virtual hardware type of the system${RESET}"
echo -e "${RED}Machine ID: ${RESET}$(hostnamectl | sed -n 's/^[[:space:]]*Machine ID:[[:space:]]*//p')"
echo -e "${RED}Vendor: ${RESET}$(hostnamectl | sed -n 's/^[[:space:]]*Hardware Vendor:[[:space:]]*//p')"
echo -e "${RED}Hardware Model (Use this to search for the device on internet): ${RESET}$(hostnamectl | sed -n 's/^[[:space:]]*Hardware Model:[[:space:]]*//p')"
echo -e "${RED}System language:${RESET} ${LANG}"
echo -e "${RED}Terminal:${RESET} ${TERM}"
echo -e "${RED}Window manager:${RESET} ${XDG_CURRENT_DESKTOP}"
echo -e "${RED}Session:${RESET} ${XDG_SESSION_TYPE}"
echo -e "${RED}Number of current users using the system:${RESET} $(who | awk '{print $1}' | sort | uniq | wc -l)"
upTime=$(uptime -p)
dateTime=$(uptime -s)
echo -e "${RED}Machine running time since last reboot:${RESET} ${upTime#* }"
echo -e "${RED}Machine date / time since last reboot:${RESET} $(uptime -s | awk '{printf("%s / %s",$1,$2)}')"
echo -e "$(lvs >/dev/null 2>&1 && echo -e "${RED}LVM is active${RESET}" || echo -e "${RED}LVM is not active${RESET}")"

# Kernel version + archi
echo -e "\n==Kernel info=="
echo -e "${RED}Kernel version:${RESET} $(uname -s), $(uname -r)"

#Disk
echo -e "\n==Disk=="
USER_ACC=""
if [[ $(whoami) == "root" ]]; then
  USER_ACC=/
else
  USER_ACC="/home/$(whoami)"
fi
echo -e "${RED}Current user filesystem:${RESET} $(df -h ${USER_ACC} | awk 'NR==2 {print $1}')"
echo -e "${RED}Total disk space:${RESET} $(df -h ${USER_ACC} | awk 'NR==2 {print $2}')"
echo -e "${RED}Total used space:${RESET} $(df -h ${USER_ACC} | awk 'NR==2 {print $3", Total: "$5}')"
echo -e "${RED}Remaining disk space:${RESET} $(df -h ${USER_ACC} | awk 'NR==2 {print $4}')"

#Memory
echo -e "\n==Memory=="
echo -e "${RED}Currently used memory:${RESET} $(free -h | awk 'NR==2 {print $3}')"
echo -e "${RED}Currently available memory:${RESET} $(free -h | awk 'NR==2 {print $7}')"
echo -e "${RED}Memory utilization rate:${RESET} $(free | awk 'NR==2 {printf("%.2f%%\n",$3/$2 * 100)}')"
echo -e "${RED}Swap used:${RESET} $(free -h | awk 'NR==3 {print $3}')"
echo -e "${RED}Swap free:${RESET} $(free -h | awk 'NR==3 {print $4}')"

#CPU info --> /proc/cpuinfo
echo -e "\n==CPU=="
echo -e "${RED}Current utilization of CPU:${RESET} $(top -bn1 | grep "Cpu(s)" | awk '/id/ {printf("%.2f%", 100-$8)}')"
cpuModel=$(cat /proc/cpuinfo | grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2)
echo -e "${RED}Model Name:${RESET} ${cpuModel#* }"
echo -e "${RED}CPU Archi type:${RESET} $(uname -m)"
thread_per_core=$(lscpu | grep -i thread | sed 's/[^0-9]//g')
total_num_of_cores_per_socket=$(lscpu | grep -i "^core" | sed 's/[^0-9]//g')
total_num_of_sockets=$(lscpu | grep -i "^socket" | sed 's/[^0-9]//g')
total_core=$((total_num_of_cores_per_socket * total_num_of_sockets))
total_threads=$((total_core * thread_per_core))
echo -e "${RED}CPU total cores:${RESET} ${total_core}"
echo -e "${RED}CPU total threads:${RESET} ${total_threads}"
#Temp
cpu_temp=$(for zone in /sys/class/thermal/thermal_zone*; do
  if [[ $(cat "$zone/type") == "x86_pkg_temp" ]]; then
    awk '{print $1/1000 "°C"}' "$zone/temp"
  fi
done)

echo -e "${RED}CPU Temp:${RESET} $cpu_temp -> ${BLUE}Note: Temperature detection may not be accurate on all systems.
If a value appears, it is likely correct, but you should verify
your CPU thermal zone or sensor configuration.${RESET}"

#GPU info
echo -e "\n==GPU=="
##list pci devices
## IFS = internal field separator --> It used to split word in bash, it's a default value, I turn it off here to not allow separation by space
echo -e "${BLUE}More information about GPU's could be found by installing \"lshw\"${RESET}"
i=1
while IFS= read -r line; do
  echo -e "${RED}GPU number ${i} used:${RESET}${line##*:}"
  ((i += 1))
done < <(lspci | grep -i vga)
((i -= 1))
echo -e "${RED}Number of GPU's:${RESET} ${i}"

#Networking
echo -e "\n==Networking=="

## ip route --> showing route table: specific rules your system used to decide where to send packets
## This command will give us the exact network interface used by the system (wifi or ethernet)
interface=$(ip route get 1.1.1.1 | awk '{print $5}')
if [[ $interface == wl* ]]; then
  echo -e "${BOLD}This device connected by ${RED}WIFI${RESET}"
  echo -e "${RED}Hostname:${RESET} $(cat /etc/hostname)"
  echo -e "${RED}Public IP address:${RESET} $(curl ifconfig.me 2>/dev/null)"

  echo -e "${RED}Private IP address (wifi):${RESET} $(ip route get 1.1.1.1 | awk '{print $7}')"
  echo -e "${RED}MAC address (wifi):${RESET} $(ip link show "$interface" | grep -i link | awk '{print $2}')"
elif [[ $interface == en* ]]; then
  echo -e "${BOLD}This device connected by ${RED}Ethernet${RESET}"
  echo -e "${RED}Hostname:${RESET} $(cat /etc/hostname)"
  echo -e "${RED}Public IP address:${RESET} $(curl ifconfig.me 2>/dev/null)"

  echo -e "${RED}Private IP address (ethernet):${RESET} $(ip route get 1.1.1.1 | awk '{print $7}')"
  echo -e "${RED}MAC address (ethernet):${RESET} $(ip link show "$interface" | grep -i link | awk '{print $2}')"
else
  echo -e "${RED}Unkown network interface!!"
fi

# Number of connections with servers or services or applications
echo -e "\n==Number of connections=="

echo -e "${RED}Number of active connections with other services/ devices/ applications:${RESET} $(ss -tun | grep -i estab | wc -l)"
