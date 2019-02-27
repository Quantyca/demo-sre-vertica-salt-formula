{% set vertica_user = salt['pillar.get']('vertica_user', 'dbadmin') %}
{% set vertica_group = salt['pillar.get']('vertica_group', 'verticadba') %}
{% set tech_user = salt['pillar.get']('tech_user', 'tech_user') %}
{% set tech_user_home = salt['pillar.get']('tech_user_home', '/home/' + tech_user) %}
{% set options = salt['pillar.get']('options', '') %}
{% set data_dir = salt['pillar.get']('data_dir', '/home/dbadmin/data') %}
{% set dbadmin_passwd = salt['pillar.get']('dbadmin_passwd', 'vertica') %}
{% set flat_list = [] %}
{% for sublist in salt['mine.get']('roles:vertica_*','vertica-addrs', 'grain').values() %}
  {% for item in sublist %}
    {% do flat_list.append(item) %}
  {% endfor %}
{% endfor %}

#2 - Installazione rpm
#
{% if salt['grains.get']('vertica_installed', False) == False %}
install_vertica_rpm:
  pkg.installed:
    - name: vertica
    - sources:
      - vertica: salt://setups/vertica/packages/vertica.rpm

#3 - Installazione vertica
#
#3.1
install_vertica_app:
  cmd.run:
{% if options %}
    - name: sudo /opt/vertica/sbin/install_vertica --hosts {{ ','.join(flat_list |sort) }} --rpm /var/cache/salt/minion/files/base/setups/vertica/packages/vertica.rpm --data-dir {{ data_dir }} -p "{{ dbadmin_passwd }}" -u {{ vertica_user }} -g {{ vertica_group }} -i {{ tech_user_home }}/.ssh/id_rsa -Y {{ options }}
{% else %}
    - name: sudo /opt/vertica/sbin/install_vertica --hosts {{ ','.join(flat_list |sort) }} --rpm /var/cache/salt/minion/files/base/setups/vertica/packages/vertica.rpm --data-dir {{ data_dir }} -p "{{ dbadmin_passwd }}" -u {{ vertica_user }} -g {{ vertica_group }} -i {{ tech_user_home }}/.ssh/id_rsa -Y
{% endif %}
    - use_vt: True
    - runas: {{ tech_user }}
    - require:
      - pkg: install_vertica_rpm

Create Database:
  cmd.run:
    - name: su - dbadmin -c "/opt/vertica/bin/admintools -t create_db -d vertica -p 'Vertica123!' -s {{ ','.join(flat_list |sort) }}"
    - require:
      - cmd: install_vertica_app

Set restart policy to always:
  cmd.run:
    - name: su - dbadmin -c "/opt/vertica/bin/admintools -t set_restart_policy -d vertica -p always"
    - require:
      - cmd: Create Database

Set grain for vertica_installed:
  grains.present:
    - name: vertica_installed
    - value: True
    - parallel: True
    - require:
      - cmd: '*'
{% endif %}
