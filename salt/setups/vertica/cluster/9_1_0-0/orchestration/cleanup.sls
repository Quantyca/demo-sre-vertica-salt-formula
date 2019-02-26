{% set tech_user = salt['pillar.get']('tech_user', 'tech_user') %}
{% set tech_user_home = salt['pillar.get']('tech_user_home', '/home/' + tech_user) %}

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

