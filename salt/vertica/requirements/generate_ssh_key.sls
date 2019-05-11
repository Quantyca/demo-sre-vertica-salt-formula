{% from "vertica/map.jinja" import tech_user with context %}
{% from "vertica/map.jinja" import tech_user_home with context %}

Generate_ssh_key on vertica init:
  cmd.run:
    - name: ssh-keygen -q -N '' -f {{ tech_user_home }}/.ssh/id_rsa
    - unless: test -f {{ tech_user_home }}/.ssh/id_rsa
    - runas: {{ tech_user }}

Create empty ssh config file:
  file.touch:
    - name: {{ tech_user_home }}/.ssh/config

Disable the StrictHostKeyChecking ssh option:
  file.append:
    - name: {{ tech_user_home }}/.ssh/config
    - text:
        - StrictHostKeyChecking no
    - require:
      - file: Create empty ssh config file
