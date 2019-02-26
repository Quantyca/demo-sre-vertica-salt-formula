{% set options = salt['pillar.get']('options', ' ') %}
{% set data_dir = salt['pillar.get']('data_dir', '/home/dbadmin/data') %}
{% set dbadmin_passwd = salt['pillar.get']('dbadmin_passwd', 'Vertica!') %}
{% set dev = pillar['dev'] %}
{% set vertica_user = salt['pillar.get']('vertica_user', 'dbadmin') %}
{% set vertica_group = salt['pillar.get']('vertica_group', 'verticadba') %}
{% set vertica_user_home = salt['pillar.get']('vertica_user_home', '/home/' + vertica_user) %}
{% set tech_user = salt['pillar.get']('tech_user', 'tech_user') %}
{% set tech_user_home = salt['pillar.get']('tech_user_home', '/home/' + tech_user) %}

#1
Check Requirements:
  salt.state:
    - sls: setups.vertica.prerequisites
    - tgt: 'roles:vertica_*'
    - tgt_type: grain
    - pillar:
        dev: {{ dev }}
        tech_user: {{ tech_user }}
        tech_user_home: {{ tech_user_home }}

#2
generate_ssh_key:
  salt.state:
    - sls: setups.vertica.prerequisites.ssh_keygen
    - tgt: 'roles:vertica_init'
    - tgt_type: grain
    - require:
      - salt: Check Requirements
    - pillar:
        tech_user: {{ tech_user }}
        tech_user_home: {{ tech_user_home }}

Refresh Mine functions:
    salt.state:
    - sls: setups.vertica.prerequisites.refresh
    - tgt: 'roles:vertica_*'
    - tgt_type: grain
    - require:
      - salt: generate_ssh_key

#3
Propagate ssh-key on all host for passwordless setup:
  salt.state:
    - sls: setups.vertica.prerequisites.ssh_key
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
    - sls: setups.vertica.cluster.9_1_0-0.orchestration.install_vertica
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
    - sls: setups.vertica.cluster.9_1_0-0.orchestration.check_data_dir
    - tgt: 'roles:vertica_*'
    - tgt_type: grain
    - require:
      - salt: Install Vertica from one node and propagate it on all nodes
    - pillar:
        data_dir: {{ data_dir }}
        vertica_user: {{ vertica_user }}
        vertica_user_home: {{ vertica_user_home }}

#6
Cleanup:
  salt.state:
    - sls: setups.vertica.cluster.9_1_0-0.orchestration.cleanup
    - tgt: 'roles:vertica_*'
    - tgt_type: grain
    - require:
      - salt: Check for data dir
    - pillar:
        data_dir: {{ data_dir }}
        tech_user: {{ tech_user }}
        tech_user_home: {{ tech_user_home }}