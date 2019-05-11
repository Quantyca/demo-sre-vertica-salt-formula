{% from "vertica/map.jinja" import data_dir with context %}
{% from "vertica/map.jinja" import vertica_user with context %}
{% from "vertica/map.jinja" import vertica_group with context %}
{% from "vertica/map.jinja" import tech_user with context %}
{% from "vertica/map.jinja" import tech_user_home with context %}

#3.2
check_own_directory:
  file.directory:
    - name: {{ data_dir }}
    - user: {{ vertica_user }}
    - group: {{ vertica_group }}
    - recurse:
      - user
      - group
