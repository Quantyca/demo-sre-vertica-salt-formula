Make sure that pillar directory exists:
  file.directory:
    - name: /srv/pillar

Make sure that top.sls file exists:
  file.managed:
    - name: /srv/pillar/top.sls

Append link to mine functions:
  file.append:
    - name: /srv/pillar/top.sls
    - text: |
        base:
          '*':
            - mine

Create mine functions file:
  file.managed:
    - name: /srv/pillar/mine.sls
    - contents: |
        mine_functions:
          vertica-addrs:
            mine_function: network.ip_addrs
            interface: eth1
          vertica_init_pubkey:
            mine_function: ssh.user_keys
            user: tech_user

