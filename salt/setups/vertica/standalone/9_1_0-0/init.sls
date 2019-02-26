{% set data_dir = salt['pillar.get']('data_dir', '/home/dbadmin/data') %}
{% set dbadmin_passwd = salt['pillar.get']('dbadmin_passwd', 'Vertica!') %}
{% set flat_list = [] %}
{% for sublist in salt['mine.get']('roles:vertica_*','vertica-addrs', grain).values() %}
  {% for item in sublist %}
    {% do flat_list.append(item) %}
  {% endfor %}
{% endfor %}

#1 Include requirements state
include:
  - setups.vertica.prerequisites

#2 - Installazione rpm
#
#2.1 - Scaricare sulla macchna rpm corretto (versione giusta)

install_vertica_rpm:
  pkg.installed:
    - name: vertica
    - sources:
      - vertica: salt://setups/vertica/packages/vertica-9.1.0-0.x86_64.RHEL6.rpm

#3 - Installazione vertica
#
#3.1
install_vertica_app:
  cmd.run:
    - name: /opt/vertica/sbin/install_vertica --hosts {{ flat_list[0] }} --rpm /var/cache/salt/minion/files/base/setups/vertica/packages/vertica-9.1.0-0.x86_64.RHEL6.rpm --data-dir {{ data_dir }} -p "{{ dbadmin_passwd }}" --accept-eula

#3.2
check_own_directory:
  file.directory:
    - name: {{ data_dir }}
    - user: dbadmin
    - group: verticadba
    - recurse:
      - user
      - group

