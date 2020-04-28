{% from "vertica/map.jinja" import vertica_user with context %}
{% from "vertica/map.jinja" import dbadmin_passwd with context %}
{% from "vertica/map.jinja" import vertica_db with context %}

{% set flat_list = [] %}
{% for sublist in salt['mine.get']('I@role:vertica_init or I@role:vertica_node','vertica-addrs', 'compound').values() %}
  {% for item in sublist %}
    {% do flat_list.append(item) %}
  {% endfor %}
{% endfor %}

Create Database:
  cmd.run:
    - name: su - {{vertica_user}} -c "/opt/vertica/bin/admintools -t create_db -d {{vertica_db}} -p '{{dbadmin_passwd}}' -s {{ ','.join(flat_list |sort) }} --skip-fs-checks"

Set restart policy to always:
  cmd.run:
    - name: su - {{vertica_user}} -c "/opt/vertica/bin/admintools -t set_restart_policy -d {{vertica_db}} -p always"
    - require:
      - cmd: Create Database
