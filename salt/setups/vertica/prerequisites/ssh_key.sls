{% set tech_user = salt['pillar.get']('tech_user', 'tech_user') %}
{% set tech_user_home = salt['pillar.get']('tech_user_home', '/home/' + tech_user) %}

Create ssh directory if doesn't exists:
  file.directory:
    - name: {{ tech_user_home }}/.ssh

{% for user, key in salt['mine.get']('roles:vertica_init','vertica_init_pubkey', 'grain').iteritems() %}
Set Vertica Init pubkey in auth file on minions:
  ssh_auth.present:
    - name: {{ key[tech_user]['id_rsa.pub'] }}
    - user: {{ tech_user }}
{% endfor %}
