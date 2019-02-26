{% set tech_user = salt['pillar.get']('tech_user', 'tech_user') %}
{% set tech_user_home = salt['pillar.get']('tech_user_home', '/home/' + tech_user) %}
{% set data_dir = salt['pillar.get']('data_dir', '/home/dbadmin/data') %}
{% set vertica_user = salt['pillar.get']('vertica_user', 'dbadmin') %}
{% set vertica_group = salt['pillar.get']('vertica_group', 'verticadba') %}
#3.2
check_own_directory:
  file.directory:
    - name: {{ data_dir }}
    - user: {{ vertica_user }}
    - group: {{ vertica_group }}
    - recurse:
      - user
      - group
