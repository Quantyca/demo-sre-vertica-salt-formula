{% from "vertica/map.jinja" import tech_user with context %}
{% from "vertica/map.jinja" import tech_user_home with context %}

Delete Tech User:
  user.absent:
    - name: {{ tech_user }}
    - purge: True

Delete group from sudoers:
  file.line:
    - name: /etc/sudoers
    - match: |
        {{ tech_user }}        ALL=(ALL)       NOPASSWD: ALL
    - mode: delete

