{% from "vertica/map.jinja" import options with context %}
{% from "vertica/map.jinja" import data_dir with context %}
{% from "vertica/map.jinja" import dbadmin_passwd with context %}
{% from "vertica/map.jinja" import vertica_user with context %}
{% from "vertica/map.jinja" import vertica_group with context %}
{% from "vertica/map.jinja" import vertica_user_home with context %}
{% from "vertica/map.jinja" import tech_user with context %}
{% from "vertica/map.jinja" import tech_user_home with context %}

#1
Check Requirements:
  salt.state:
    - sls: setups.vertica.requirements
    - tgt: 'roles:vertica_*'
    - tgt_type: grain
    - pillar:
        dev: {{ dev }}
        tech_user: {{ tech_user }}
        tech_user_home: {{ tech_user_home }}

#2
generate_ssh_key:
  salt.state:
    - sls: setups.vertica.requirements.generate_ssh_key
    - tgt: 'roles:vertica_init'
    - tgt_type: grain
    - require:
      - salt: Check Requirements
    - pillar:
        tech_user: {{ tech_user }}
        tech_user_home: {{ tech_user_home }}

Refresh Mine functions:
    salt.state:
    - sls: setups.vertica.requirements.mine_refresh
    - tgt: 'roles:vertica_*'
    - tgt_type: grain
    - require:
      - salt: generate_ssh_key

#3
Propagate ssh-key on all host for passwordless setup:
  salt.state:
    - sls: setups.vertica.requirements.propagate_ssh_key
    - tgt: 'roles:vertica_node'
    - tgt_type: grain
    - require:
      - salt: Refresh Mine functions
    - pillar:
        tech_user: {{ tech_user }}
        tech_user_home: {{ tech_user_home }}

#4
Install Vertica from one node and propagate it on all nodes:
  salt.state:
    - sls: setups.vertica.orchestration.install_vertica
    - tgt: 'roles:vertica_init'
    - tgt_type: grain
    - require:
      - salt: Propagate ssh-key on all host for passwordless setup
    - pillar:
        data_dir: {{ data_dir }}
        dbadmin_passwd: {{ dbadmin_passwd }}
        options: {{ options }}
        tech_user: {{ tech_user }}
        tech_user_home: {{ tech_user_home }}
        vertica_user: {{ vertica_user }}
        vertica_user_home: {{ vertica_user_home }}
        vertica_group: {{ vertica_group }}

#5
Check for data dir:
  salt.state:
    - sls: setups.vertica.orchestration.check_data_dir
    - tgt: 'roles:vertica_*'
    - tgt_type: grain
    - require:
      - salt: Install Vertica from one node and propagate it on all nodes
    - pillar:
        data_dir: {{ data_dir }}
        vertica_user: {{ vertica_user }}
        vertica_user_home: {{ vertica_user_home }}

#6
Create Vertica Database:
  salt.state:
    - sls: setups.vertica.orchestration.create_database
    - tgt: 'roles:vertica_init'
    - tgt_type: grain
    - pillar:
        vertica_user: {{ vertica_user }}
        dbadmin_passwd: {{ dbadmin_passwd }}
        vertica_db: {{ vertica_db }}
    - require:
      - salt: Check for data dir

#7
Cleanup:
  salt.state:
    - sls: setups.vertica.orchestration.cleanup
    - tgt: 'roles:vertica_*'
    - tgt_type: grain
    - require:
      - salt: Create Vertica Database
    - pillar:
        data_dir: {{ data_dir }}
        tech_user: {{ tech_user }}
        tech_user_home: {{ tech_user_home }}
