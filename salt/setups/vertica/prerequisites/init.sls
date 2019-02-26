{% set timezone = salt['pillar.get']('timezone', 'Europe/Rome') %}
{% set dev = pillar['dev'] %}
{% set fstype = salt['disk.fstype'](dev) %}
{% set tech_user = salt['pillar.get']('tech_user', 'tech_user') %}
{% set tech_user_home = salt['pillar.get']('tech_user_home', '/home/' + tech_user) %}

#1 - Verifica e Installazione prerequisiti
#
#1.1 Verifica OS
{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'] in [6,7] %}

#1.2 
Set Swappiness to 1:
  sysctl.present:
   - name: vm.swappiness
   - value: 1

#1.3 
Check if all needed packages are installed:
  pkg.installed:
    - pkgs:
      - openssh
      - bash
      - sudo
      - policycoreutils-python
      - selinux-policy-targeted
      - tuned
      - mcelog
      - sysstat
      - dialog
      - gdb
{% if grains['osmajorrelease'] == 7 %}
      - chrony
      - gdb
{% else %}
      - ntp
{% endif %}

#1.4 Check Filesystem Type
{% if fstype == 'ext4' %}
echo File system is OK, {{ fstype }}:
  cmd.run
{% else %}
damn, File System is not ext4 but {{ fstype }}:
  cmd.run:
    - failhard: True
{% endif %}

#1.5 Check if Swap is > 2Gb
{% for devs, specs in salt['mount.swaps']().iteritems() %}
{% if specs['size'] | int < 2000000 %}
damn, Swap Size less than 2GB, the size is {{ specs['size'] }}:
  cmd.run:
    - failhard: True
{% else %}
echo Swap Size OK, {{ specs['size'] }}:
  cmd.run
{% endif %}
{% endfor %}

#1.6
{% if not salt['disk.dump'](dev)['getra'] | int > 4095 %}
Set Disk Read Ahead:
  blockdev.tuned:
    - name: {{ dev }}
    - read-ahead: 4096
{% else %}
echo Read ahead OK, {{ salt['disk.dump'](dev)['getra'] }}:
  cmd.run
{% endif %}

#1.7
{% if grains['osmajorrelease'] == 7 %}
Start Chrony Service:
  service.running: 
    - name: chronyd
    - enable: True
{% else %}
Start NTP Service:
  service.running:
    - name: ntpd
    - enable: True
{% endif %}

#1.8
Set SeLinux in Permissive Mode:
  selinux.mode:
    - name: permissive

#1.9 ##### Verificare questo step #####
Set tuned daemon profile to latency-performance:
  service.running:
    - name: tuned
    - enable: True
  tuned.profile:
    - name: throughput-performance

#1.10
Check if rc.local file has requirements:
  file.append:
    - name: /etc/rc.d/rc.local
    - text: |
        # Added by Salt
        # I/O Scheduler
        {%- if 'mapper' in dev %}
        {%- set dev_for_scheduler = salt['cmd.run']("lsblk | grep -B 1 "+ dev.split('/')[-1] +" | head -1 | awk '{print $1}' | sed 's/[0-9]*//g'", python_shell=True) %}
        echo deadline > /sys/block/{{ dev_for_scheduler|replace('-', '')|replace('`','') }}/queue/scheduler
        {%- else %}
        echo deadline > /sys/block/{{ dev.split('/')[-1].strip('0123456789 ') }}/queue/scheduler
        {%- endif %}

        {%- if grains['osmajorrelease'] == 7 %}
        # Enable Transparent Hugepages
        if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
          echo always > /sys/kernel/mm/transparent_hugepage/enabled
        fi
        {%- else %}
        if test -f /sys/kernel/mm/redhat_transparent_hugepage/enabled; then
          echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
        fi
        {%- endif %}

        # Disable Defrag
        if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
          echo never > /sys/kernel/mm/transparent_hugepage/defrag
        fi


#1.11
{% if grains['osmajorrelease'] == 6 %}
Disable Transparent Huge Pages if major release is 6:
  sysctl.present:
    - name: vm.nr_hugepages
    - value: 0
{% endif %}

#1.12
Set execution flag to /etc/rc.d/rc.local:
  file.managed:
    - name: /etc/rc.d/rc.local
    - mode: 755

#1.13
Run prerequisites bootstrap:
  cmd.run:
    - name: /etc/rc.d/rc.local
    - onchanges:
      - file: Check if rc.local file has requirements

#1.14
Set Timezone to:
  timezone.system:
    - name: {{ timezone }}

Create Tech User:
  user.present:
    - name: {{ tech_user }}
    - fullname: {{ tech_user }}
    - shell: /bin/bash
    - home: {{ tech_user_home }}

Add group for sudoers:
  file.append:
    - name: /etc/sudoers
    - text: |
        {{ tech_user }}        ALL=(ALL)       NOPASSWD: ALL
{% else %}
{% do salt['test.exception']("OS is not Centos or RedHat or your version in not supported!") %}
{% endif %}
