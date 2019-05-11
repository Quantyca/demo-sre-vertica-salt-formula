{% from "vertica/map.jinja" import tech_user with context %}
{% from "vertica/map.jinja" import tech_user_home with context %}

Create ssh directory if doesn't exists:
  file.directory:
    - name: {{ tech_user_home }}/.ssh

{% for user, key in salt['mine.get']('roles:vertica_init','vertica_init_pubkey', 'grain').iteritems() %}
Set Vertica Init node pubkey in authorization file on minions:
  ssh_auth.present:
    - name: {{ key[tech_user]['id_rsa.pub'] }}
    - user: {{ tech_user }}
{% endfor %}
