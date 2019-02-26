#!/bin/bash

if [ -z "$1" -o -z "$2" ]; then
echo -e "You have to pass your device and your Timezone\nUSAGE: $0 /dev/[device] [Europe/Rome]"
exit 1
fi

color_reset=$(tput -Txterm sgr0)

if [ ! $(whoami) == root ]; then
echo -e '\E[31m'"Avviare il programma con utenza di root" $color_reset
exit 1
fi

#Controllo se il sistema operativo è un RedHat:
grep "redhat" /etc/*release* | grep 7 > /dev/null
exit_1=$?
grep "centos:7" /etc/*release* > /dev/null
exit_2=$?
if [ $(($exit_1 + $exit_2)) -eq 2 ]; then
echo -e '\E[31m'"Il sistema operativo non è RedHat 7 o CentOs 7" $color_reset
exit 1
fi

#Bash shell:
getent passwd | grep root | grep bash > /dev/null
if [ $? -eq 0 ]; then
  echo -e '\E[32m'"- Verifica Bash -- OK" $color_reset
  else
  echo -e '\E[31m'"Imposto la shell di default a bash" $color_reset
  chsh -s /bin/bash
fi

#Verify Sudo:
rpm -qa | grep -w sudo > /dev/null
if [ $? -eq 0 ]; then
  echo -e '\E[32m'"- Verifica Sudo -- OK" $color_reset
else
  echo -e '\E[31m'"Installo Sudo" $color_reset
  yum -y install sudo
fi

#Verifico che il filesystem è un ext4:
#echo -n -e '\E[32m'"Inserire il nome del device su cui installare Vertica" $color_reset
#device="$1"
#if [ ! "$(df -T | grep $device | awk '{print $2}')" == "ext4" ]; then
#  echo -e '\E[31m'"La partizione non è in ext4. Esco" $color_reset
#  exit 1
#else
#  echo -e '\E[32m'"- Verifica partizione ext4 -- OK" $color_reset
#fi

#Swap Space Requirements:
if [ $(free -g | grep -i swap | awk '{print $2}') -le 2 ]; then
  echo -e '\E[31m'"Lo spazio disponibile per la Swap è minore di 2Gb" $color_reset
  exit 1
else
  echo -e '\E[32m'"- Verifica Swap -- OK" $color_reset
fi

#Disk Block Size Requirements
blksize=$(dumpe2fs $device | grep "Block size" | awk '{print $3}')
if [ $blksize -eq 4096 ]; then
  echo -e '\E[32m'"- Verifica Block Size: $blksize -- OK" $color_reset
else
  echo -e '\E[31m'"Il Block size è diverso da 4096" $color_reset
fi

#Configuring Operating System Settings
#Verifica Disk Readahead
readahead=$(/sbin/blockdev --getra $device)
if [ $readahead -ge 2048 ]; then
  echo -e '\E[32m'"- Verifica Disk Readahead: $readahead -- OK" $color_reset
else
  echo -e '\E[31m'"Configuro il Disk Readahead" $color_reset
  echo "#Added by GDA" >> /etc/rc.local
  echo "/sbin/blockdev --setra 2048 $device" >> /etc/rc.local
  /sbin/blockdev --setra 2048 $device
fi

#Enabling chrony for Red Hat 7/CentOS 7 Systems
systemctl list-unit-files | grep chronyd > /dev/null
if [ $? -eq 0 ]; then
  echo -e '\E[32m'"- Verifica chronyd.service -- OK" $color_reset
else
  echo -e '\E[31m'"Installo e attivo chronyd.service" $color_reset
  yum -y install chrony
  systemctl status chronyd
  if [ ! $? -eq 0 ]; then
    systemctl start chronyd
  fi
  systemctl enable chronyd
fi

#SELinux Configuration
getenforce > /dev/null
if [ $? -eq 0 ];then
  if [ $(getenforce) == Permissive -o $(getenforce) == Disabled ]; then
    echo -e '\E[32m'"- Verifica SELinux -- OK" $color_reset
  else
    echo -e '\E[31m'"Disattivo SELinux" $color_reset
    setenforce 0
    sed -i 's/^SELINUX=.*$/SELINUX=permissive/g' /etc/selinux/config
  fi
else
  echo -e '\E[32m'"SELINUX non installato" $color_reset
fi

#Enable Transparent Hugepages on Red Hat 7/CentOS 7 Systems
cat /sys/kernel/mm/transparent_hugepage/enabled | grep "[[a]lways]"
if [ $? -eq 0 ]; then
  echo -e '\E[32m'"- Verifica Transparent Hugepages -- OK" $color_reset
else
  echo -e '\E[31m'"Attivo Transparent Hugepages" $color_reset
  echo always > /sys/kernel/mm/transparent_hugepage/enabled
  cat <<EOF >> /etc/rc.local

#Enable Transparent Hugepages
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
  echo always > /sys/kernel/mm/transparent_hugepage/enabled
fi
EOF
fi

#Disable Defrag on Red Hat 7/CentOS 7 Systems
cat /sys/kernel/mm/transparent_hugepage/defrag | grep "[[n]ever]"
if [ $? -eq 0 ]; then
  echo -e '\E[32m'"- Verifica Defrag -- OK" $color_reset
else
  echo -e '\E[31m'"Disattivo Defrag" $color_reset
  echo never > /sys/kernel/mm/transparent_hugepage/defrag
  cat <<EOF >> /etc/rc.local

#Disable Defrag
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
  echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
EOF
fi

#I/O Scheduler 
spec_dev=$(echo $device | awk -F "/" '{print $3}')
cat /sys/block/$spec_dev/queue/scheduler | grep "[[d]eadline]"
if [ $? -eq 0 ]; then
  echo -e '\E[32m'"- Verifica I/O Scheduler -- OK" $color_reset
else
  echo -e '\E[31m'"- Imposto a deadline il I/O Scheduler" $color_reset
  echo deadline > /sys/block/$spec_dev/queue/scheduler
  cat <<EOF >> /etc/rc.local

#I/O Scheduler
echo deadline > /sys/block/$spec_dev/queue/scheduler
EOF
fi

#Tools
echo -e '\E[32m'"Installo i tools di supporto" $color_reset
rpm -qa | grep -w [g]db
if [ ! $? -eq 0 ]; then
  yum -y install gdb
fi

rpm -qa | grep -w [m]celog
if [ ! $? -eq 0 ]; then
  yum -y install mcelog
fi

rpm -qa | grep -w [s]ysstat
if [ ! $? -eq 0 ]; then
  yum -y install sysstat
fi

rpm -qa | grep -w [d]ialog
if [ ! $? -eq 0 ]; then
  yum -y install dialog
fi

rpm -qa | grep -w [w]hich
if [ ! $? -eq 0 ]; then
  yum -y install which
fi

rpm -qa | grep -w [o]penssh
if [ ! $? -eq 0 ]; then
  yum -y install openssh
fi



#TZ Environment Variable
rpm -qa | grep tzdata
if [ ! $? -eq 0 ]; then
  yum -y install tzdata
fi

#Setting the Time Zone on a Host

echo -e '\E[32m'"Set Host Timezone to $2" $color_reset
timezone="$2"
export TZ="$timezone"
cat <<EOF >> /etc/profile.d/timezone.sh

#TZ 
export TZ="$timezone"
EOF
fi

echo -e '\E[31m'"disable CPU scaling in BIOS" $color_reset
echo -e '\E[32m'"- FINE DELLO SCRIPT" $color_reset
