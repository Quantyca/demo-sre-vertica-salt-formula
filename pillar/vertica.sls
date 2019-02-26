dev: /dev/sda1

mine_functions:
  vertica-addrs:
    mine_function: network.ip_addrs
    interface: eth1
  vertica_init_pubkey:
    mine_function: ssh.user_keys
    user: tech_user

