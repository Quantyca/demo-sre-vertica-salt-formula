{% set flat_list = [] %}
{% for sublist in salt['mine.get']('roles:vertica_*','vertica-addrs', 'grain').values() %}
  {% for item in sublist %}
    {% do flat_list.append(item) %}
  {% endfor %}
{% endfor %}

Create Database:
  cmd.run:
    - name: su - dbadmin -c "/opt/vertica/bin/admintools -t create_db -d vertica -p 'Vertica123!' -s {{ ','.join(flat_list |sort) }}"

Set restart policy to always:
  cmd.run:
    - name: su - dbadmin -c "/opt/vertica/bin/admintools -t set_restart_policy -d vertica -p always"
    - require:
      - cmd: Create Database
