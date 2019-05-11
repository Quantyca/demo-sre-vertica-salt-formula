{% from "vertica/map.jinja" import options with context %}
{% from "vertica/map.jinja" import data_dir with context %}
{% from "vertica/map.jinja" import dbadmin_passwd with context %}
{% from "vertica/map.jinja" import vertica_user with context %}
{% from "vertica/map.jinja" import vertica_group with context %}
{% from "vertica/map.jinja" import vertica_user_home with context %}
{% from "vertica/map.jinja" import tech_user with context %}
{% from "vertica/map.jinja" import tech_user_home with context %}
{% from "vertica/map.jinja" import vertica_rpm with context %}
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
      - vertica: salt://vertica/packages/vertica.rpm

#3 - Installazione vertica
#
#3.1
install_vertica_app:
  cmd.run:
{% if options %}
    - name: sudo /opt/vertica/sbin/install_vertica --hosts {{ ','.join(flat_list |sort) }} --rpm /var/cache/salt/minion/files/base/vertica/packages/vertica.rpm --data-dir {{ data_dir }} -p "{{ dbadmin_passwd }}" -u {{ vertica_user }} -g {{ vertica_group }} -i {{ tech_user_home }}/.ssh/id_rsa -Y {{ options }}
{% else %}
    - name: sudo /opt/vertica/sbin/install_vertica --hosts {{ ','.join(flat_list |sort) }} --rpm /var/cache/salt/minion/files/base/vertica/packages/vertica.rpm --data-dir {{ data_dir }} -p "{{ dbadmin_passwd }}" -u {{ vertica_user }} -g {{ vertica_group }} -i {{ tech_user_home }}/.ssh/id_rsa -Y
{% endif %}
    - use_vt: True
    - runas: {{ tech_user }}
    - require:
      - pkg: install_vertica_rpm

Set grain for vertica_installed:
  grains.present:
    - name: vertica_installed
    - value: True
    - parallel: True
    - require:
      - cmd: '*'
{% else %}
Step vertica_installed already done:
  test.configurable_test_state:
    - name: Step vertica_installed already done
    - changes: False
    - result: True
    - comment: Step vertica_installed already done
{% endif %}
