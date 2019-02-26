### What is this repository for? ###

* Vagrant Multi Instance:
  * Vertica Community Edition Tree Node Cluster
* Tested on 9.1.1

### Prerequisites  ###

1. Centos 7 box (virtualbox, 1811.01)
2. Vagrant installed and following plugin:
    * vagrant plugin install vagrant-vbguest
3. Vertica RPM. Click on following link to register and proceed to download:
    * https://www.vertica.com/log-in/?redirect_to=https%3A%2F%2Fwww.vertica.com%2Fdownload%2Fvertica%2Fcommunity-edition%2F

### How do I get set up? ###

Download the Vertica CE software and put it in **salt/setups/vertica/packages** folder renaming it in **vertica.rpm**.

Then run:
```bash
vagrant up
```

At the end of the bootstrap you can connect to the cluster via Sql Client, e.g [DBeaver](https://dbeaver.io/download/):

* JDBC Connection: jdbc:vertica://192.168.99.3:5433/vertica
* Credentials:
  * username: dbadmin
  * password: Vertica123!

### See also ###

* [Vertica Documentation](https://www.vertica.com/docs/9.1.x/HTML/index.htm)
* [Vagrant Documentation](https://www.vagrantup.com/docs/)
* [Salt Documentation](https://docs.saltstack.com/en/latest/)
