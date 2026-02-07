---
title: Install Adobe Campaign locally on Virtualbox
categories: [opensource,adobe campaign]
redirect_from: /install-acc
---

Local install Adobe Campaign to set up your own development environment! Useful for testing and demo. Plus, access to any VM feature such as snapshots and duplication.

![](/assets/images/2019/03/adobe-campaign-install-architecture-network.jpg)

<p class="text-center">⏬📦✔️</p>

<!--more-->

- Note: [Official AC7 Adobe installation guide](https://experienceleague.adobe.com/docs/campaign-classic/using/installing-campaign-classic/install-campaign-on-prem/installing-campaign-in-linux-/installing-packages-with-linux.html?lang=en)

## Prerequisites: CentOS 7 x64 on Virtualbox
1. Install VirtualBox from [virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
1. Get Centos ISO from [centos.org/download](https://www.centos.org/download/). I'll be using [CentOS-7-x86_64-DVD-1810.iso](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso)
1. Spin up a `Red Hat` instance with the ISO loaded and a `8gb disk`. Then, install it with the following settings:
    1. Software Selection:
        1. `Server with a GUI` > Add `PostgreSQL Database Server` & `Development Tools`
    1. `Connected to Ethernet`
    1. user `fco` with `sudo` privileges
![](/assets/images/2019/02/fedora-workstation-install-disk.jpg)
1. Restart the machine, accept the licence and log in
1. Open up a terminal. You should have the following:
![](/assets/images/2019/02/fedora-workstation-first-terminal.jpg)

Optional notes:
- [Youtube tutorial to install CentOS 7 on VirtualBox](https://www.youtube.com/watch?v=Pcl417NR2xc)
- Install Virtual Box Guest Addition to enable copy/paste:

```bash
sudo yum groupinstall "Development Tools" # 111 Mb
sudo yum install kernel-devel elfutils-libelf-devel # 38 Mb
```
then VM > Devices > Install Guest Additions)

- Install Gnome instead of Gnome Classic, see [tuto on stackexchange](https://unix.stackexchange.com/questions/181503/how-to-install-desktop-environments-on-centos-7)
- see https://www.tecmint.com/things-to-do-after-minimal-rhel-centos-7-installation/#C1 for details

## Java 8 JDK
The JRE is not enough, we need the JDK via the `java-1.8.0-openjdk-devel` package:
```console
[fco@localhost ~]$ java -version
openjdk version "1.8.0_191"
OpenJDK Runtime Environment (build 1.8.0_191-b12)
OpenJDK 64-Bit Server VM (build 25.191-b12, mixed mode)
[fco@localhost ~]$ sudo yum install java-1.8.0-openjdk-devel # 194 Mb
[fco@localhost ~]$ javac -version
javac 1.8.0_191
```

## AC7 rpm package
Let's do all of our work in `~/ac`.

Download the `.rpm` file from the Download Center (Before 2022 on [support.neolane.net/webApp/downloadCenter](https://support.neolane.net/webApp/downloadCenter?__userConfig=psaDownloadCenter)). Then:
```console
[fco@localhost ~]$ cd && mkdir ac && cd ac
[fco@localhost ~/ac]$ sudo yum install -y ./nlserver6-8864-x86_64_rh7.rpm
[fco@localhost ~/ac]$ sudo service nlserver6 start # quick check
Starting nlserver6 (via systemctl):                        [  OK  ]
[fco@localhost ~/ac]$ sudo service nlserver6 status # check 2
14:20:41 >   Application server for Adobe Campaign (6.1.1 build 8864) of 03/02/2018
watchdog (3956) - 4.8 MB
syslogd@default (3529) - 12.7 MB
web@default (3740) - 106.4 MB
[fco@localhost ~/ac]$ sudo service nlserver6 stop
```

## Configure `~/.bash_profile` for user `neolane`

```console
[fco@localhost ~/ac]$ sudo su - neolane
-bash-4.2$ id && pwd && ll
uid=1001(neolane) gid=1001(neolane) groups=1001(neolane)
/usr/local/neolane
drwxrwxr-x. 14 neolane neolane 187 Feb 13 14:01 nl6
-bash-4.2$ vim ~/.bash_profile
export LD_LIBRARY_PATH=/usr/local/neolane/nl6/lib/:/usr/lib/jvm/java-1.8.0-openjdk/jre/lib/amd64/:/usr/lib/jvm/java-1.8.0-openjdk/jre/lib/amd64/server/
export PATH=$PATH:/usr/local/neolane/nl6/bin/
alias ll="ls -alh"
PS1="[\u@\h \w]\$ "
[neolane@localhost ~]$ nlserver start web
14:01:32 >   Application server for Adobe Campaign (6.1.1 build 8864) of 03/02/2018
14:01:32 >   Launching task 'web@default' ('nlserver web -tracefile:web@default -instance:default -detach -tomcat -autorepair') in a new process
14:01:32 >   Application server for Adobe Campaign (6.1.1 build 8864) of 03/02/2018
14:01:32 >   Starting Web server module (pid=9376, tid=9376)...
14:01:32 >   Tomcat started
14:01:32 >   Server started
[neolane@localhost ~]$ nlserver pdump
14:03:23 >   Application server for Adobe Campaign (6.1.1 build 8864) of 03/02/2018
web@default (9376) - 143.4 MB
```
![](/assets/images/2019/02/adobe-campaign-virtualbox-install-pdump.jpg)

## Configure the firewall

To be able to connect from our Host, we need to create new Firewall rules.

By default CentOS uses `firewall-cmd` to block incoming connections. We have to allow the ACC default port `8080` (Which is the Tomcat default port).

```console
[fco@localhost ~]$ sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
success
[fco@localhost ~]$ sudo firewall-cmd --zone=public --add-port=8080/udp --permanent
success
[fco@localhost ~]$ sudo firewall-cmd --reload
success
```

## Install postgresql
(See [https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-7](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-7))

Init PostgreSQL with a SQL user `dbuser1` (password `dbpwd1`), a SQL database `dbuser1` and a Linux user `dbuser1`:

```console
[fco@localhost ~]$ sudo yum install postgresql-server postgresql-contrib # not needed if already installed via the Centos package selection
[fco@localhost ~]$ sudo postgresql-setup initdb
Initializing database ... OK
[fco@localhost ~]$ sudo systemctl start postgresql # start PostgreSQL now
[fco@localhost ~]$ sudo systemctl enable postgresql # and at boot
[fco@localhost ~]$ sudo vim /var/lib/pgsql/data/pg_hba.conf # replace ident by md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
[fco@localhost ~]$ sudo su - postgres
[postgres@localhost ~]$ createuser --interactive # create a PostgreSQL role (user)
dbuser1
[postgres@localhost ~]$ createdb dbuser1 # create a PostgreSQL database with the same name
[postgres@localhost ~]$ psql # open the PostgreSQL shell
postgres=# ALTER USER dbuser1 PASSWORD 'dbpwd1'; # set a password for the SQL user
postgres=# \q
[postgres@localhost ~]$ exit
[fco@localhost ~]$ sudo adduser dbuser1 # create a Linux user with the same name

```

![](/assets/images/2019/02/adobe-campaign-postgresql-install.png)

You can check your PostreSQL setup by connecting to your Guest via SqlEctron (or any SQL client). To do so, some extra steps need to be taken, see [Allow external PostgreSQL access](#allow-external-postgresql-access) at the end of this article.


## Set up instance

We'll set up an instance named `instance1`, with default user `internal` and password `internal` (See [Adobe doc for nlserver config](https://docs.campaign.adobe.com/doc/AC/en/INS_Appendices_Command_lines.html)).

```console
[neolane@localhost ~]$ nlserver config -verbose -addinstance:instance1/*/eng
08:59:01 >   Creation of the server configuration file '/usr/local/neolane/nl6/conf/config-instance1.xml'
[neolane@localhost ~]$ nlserver config -internalpassword
Enter the current password.
Password: <EMPTY>
Enter the new password.
Password: internal
Confirmation: internal
16:23:48 >   Password successfully changed for account 'internal' (authentication mode 'nl').
```

Note your VM IP, next to `inet`, here `10.3.112.82`:

```console
$ ifconfig
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.3.112.82  netmask 255.255.255.0  broadcast 10.3.112.255
```

Connect with your client `internal/internal` to `http://10.3.112.82:8080`:
![](/assets/images/2019/02/adobe-campaign-login-as-internal.jpg)

You'll be prompted to set up the database:
![](/assets/images/2019/02/adobe-campaign-database-creation-wizard.jpg)
![](/assets/images/2019/02/adobe-campaign-database-creation-wizard-2.jpg)
![](/assets/images/2019/02/adobe-campaign-database-creation-wizard-packages.jpg)

Set the password for the `admin` account to `admin`:
![](/assets/images/2019/02/adobe-campaign-database-creation-wizard-creation-steps.jpg)
![](/assets/images/2019/02/adobe-campaign-database-creation-wizard-execution.jpg)

Preview of the log:
```
Submitting job to the server
16:02:10 - Enumerating the file entities...
16:02:11 - Generating schemas...
16:02:12 - Executing SQL script 'xtk:postgresql-functions.sql'...
16:02:12 - Starting 1 connection(s) on pool 'default instance1' (postgresql, server='localhost', login='dbuser1:dbuser1')
16:02:12 - Creating DDL procedures
16:02:12 - Creating standard date and time functions
[...]
16:02:24 - Installation of packages successful.
16:02:25 - Changing administrator password...
16:02:25 - Creation of database successfully completed.
```

You can now login with `admin/admin`:
![](/assets/images/2019/02/adobe-campaign-login-as-admin.jpg)

And access any feature locally:
![](/assets/images/2019/02/adobe-campaign-welcome-screen.jpg)
![](/assets/images/2019/02/adobe-campaign-navtree-successful.jpg)

For the workflows to start, you need to activate the `wfserver` process if it doesn't show up in `nlserver pdump` with
```console
$ nlserver start wfserver@instance1
```

Then create and start the first worflow `WKF1`:
![](/assets/images/2019/02/adobe-campaign-workflow-run.jpg)
![](/assets/images/2019/02/adobe-campaign-workflow-audit-log-success.jpg)

You may also access to the web based interface with the `:8080` port, such as `http://10.23.87.90:8080/view/home`:
![](/assets/images/2019/03/adobe-campaign-tomcat.jpg)

Start multi-instance modules:
```console
$ nlserver start web # already started, no needed
$ nlserver start syslogd
$ nlserver start trackinglogd
```

Start mono-instance modules:
```console
$ nlserver start wfserver@instance1 # already started, no needed
$ nlserver start mta@instance1
$ nlserver start inMail@instance1
$ nlserver start sms@instance1
$ nlserver start stat@instance1
```

*See [ACC Modules documentation](https://final-docs.campaign.adobe.com/doc/AC/en/INS_Initial_configuration_Configuring_Campaign_server.html)*

Go to `http://localhost:8080/view/supervision`:

![](/assets/images/2019/02/adobe-campaign-instance-monitoring.jpg)

## Troubleshoot
You might run into some errors while setting up the Db, the following will help:

### Debug your instance config file
Each instance is defined in `/usr/local/neolane/nl6/conf/conf-{instance-name}.xml`. Download [the example of conf-instance1.xml](/assets/adobe-campaign/conf-instance1.xml).

### Update the Db 1/2

```console
[neolane@localhost ~/nl6/datakit]$ psql -U dbuser1 -d dbuser1 -h localhost -f ./xtk/fra/sql/postgresql-nldb.sql
```
Download [the example of postgresql-nldb.sql](/assets/adobe-campaign/postgresql-nldb.sql).

### Update the Db 2/2
1. First import: core schema [db.sql](https://gist.github.com/myrosblog/14fa97cbd691f71b6bf941f0dc2c5d2d) (This file can be found in your Support Download Center)
```console
$ psql -U dbuser1 -d dbuser1  -h localhost -f adobe-campaign-install-db.sql
```
1. Second import: public procedures [update.sql](https://gist.github.com/myrosblog/56af2f0fc8b3d5d549490772655aadf5) (See Appendix to generate this file)
```console
$ psql -U dbuser1 -d dbuser1  -h localhost -f adobe-campaign-update.sql
$ nlserver package -verbose -instance:instance1 -import:xtk/eng/package/core.xml
$ psql -U dbuser1 -d dbuser1 -h localhost -f ./xtk/fra/sql/postgresql-nldb.sql
$ nlserver package -verbose -instance:instance1 -import:nl/postupgrade.xml
```
*Note: I also had to `DROP` `xtksessioninfo`, then re-create manually with [this script](https://gist.github.com/myrosblog/4439ee67487b729fcebb6376aec9e30d).*



### Download your PostreSQL procedures
Create a JS activity with below code:

```js
var f = new File('/sftp/my-instance/incoming/my-ftp-folder/my-procedures.sql');
f.open('w');

var fields = "collection,pg_get_functiondef:string";
var sql = "SELECT pg_get_functiondef(f.oid) "+
  "FROM pg_catalog.pg_proc f "+
  "INNER JOIN pg_catalog.pg_namespace n ON (f.pronamespace = n.oid) "+
  "WHERE n.nspname = 'public';";

var res = sqlSelect(fields, sql)

for each(var proc in res.collection){
  logInfo('- '+proc);
  f.writeln(proc.pg_get_functiondef.toString().replace('PARALLEL SAFE ', '')+';')
};

f.close()
```

Example of output for `GetDate()`:
```sql
CREATE OR REPLACE FUNCTION public.getdate()
 RETURNS timestamp with time zone
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select clock_timestamp() as result
$function$;
```

### Download your PostgreSQL tables
Create a JS activity with below code:

```js
var f = new File('/sftp/my-instance/incoming/my-ftp-folder/my-tables.sql');
f.open('w');

var table = 'nmsextaccount';

var sqlSchema = NLWS.xtkSqlSchema.BuildSqlSchema('default', table);
var sql = 'CREATE TABLE '+table+'(\n';
for each(var field in sqlSchema.getFirstElement('table').getElements('field')){
  //logInfo(field.$name, field.$type, field.$length);
  var type = field.$type.toLowerCase();
  switch(type){ // see https://www.postgresql.org/docs/9.3/datatype.html for datatypes
    case 'short': type = 'INTEGER'; break;
    case 'long': type = 'INTEGER'; break;
    case 'double': type = 'DOUBLE PRECISION'; break;
    case 'string': type = 'VARCHAR'; break;
    case 'memo': type = 'TEXT'; break;
    case 'datetimetz': type = 'TIMESTAMP'; break;
  };
  sql += '  '+field.$name+' '+type;
  if(field.$length){
    sql += '('+field.$length+')';
  }
  sql += ',\n';
}
sql = sql.substr(0, sql.length-2) // remove last ,\n
sql += '\n);'
logInfo(sql);
f.writeln(sql);
f.close();
```

Example of output for `NmsExtAccount`:
```sql
CREATE TABLE nmsextaccount(
  iactive INTEGER,
  iunicodedata INTEGER,
  mdata TEXT,
  saccount VARCHAR(80),
  sawskey VARCHAR(128),
  tscreated TIMESTAMP,
  tslastmodified TIMESTAMP
);
```

### Execute JS code from the commande line with `nlserver javascript`

```console
$ cat test.js
var o = NLWS.xtkOperator.load(2); loginfo(o);
$ nlserver javascript -instance:instance1 -file test.js
17:59:09 >   Application server for Adobe Campaign (6.1.1 build XXXX) of XX/XX/XXXX
17:59:09 >   Starting 1 connection(s) on pool 'default instance1' (postgresql, server='localhost', login='dbuser1:dbuser1')
17:59:09 >   Executing JavaScript from file 'test.js'...
```

## Appendixes
### Assign a static IP to the virtualbox VM
On the host, get the IP address, Subnet Mask and Default Gateway. I.e. on Windows with `ipconfig`:

![](/assets/images/2019/03/adobe-campaign-virtualbox-static-ip-host.jpg)

Values:
```
IPv4 Address. . . . . . . . . . . : 10.23.87.24
Subnet Mask . . . . . . . . . . . : 255.255.255.0
Default Gateway . . . . . . . . . : 10.23.87.1
```

It means we can choose any IP from `10.23.87.2` to `10.23.87.255` for our VM. Let's use `10.23.87.100`.

On the VM, get the interface name with `ifconfig`, here `enp0s3` in order to edit it:

![](/assets/images/2019/03/adobe-campaign-virtualbox-static-ip-vm.jpg)

```console
$ sudo vim /etc/sysconfig/network-scripts/ifcfg-enp0s3
IPADDR=10.23.87.100 # added
NETMASK=255.255.255.0 # added
GATEWAY=10.23.87.1 # added
$ sudo service network restart
```

Old: don't do `BOOTPROTO="none" # updated from "dhcp"`, it's going to disable the internet connection

### Integrate with Apache web server 
```console
$ sudo yum install -y httpd
$ sudo systemctl start httpd # start now
$ sudo systemctl enable httpd # start at boot
$ service httpd status && curl localhost # check
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2019-02-06 16:53:12 EST; 1min 22s ago
[...]</body></html>
$ sudo firewall-cmd --add-service=http --permanent # allow firewall http
$ sudo firewall-cmd --add-service=https --permanent # allow firewall https
$ sudo firewall-cmd --reload
$ sudo vim /etc/httpd/conf.modules.d/00-base.conf # comment the following modules, with a trailing #:
#auth_basic
#authn_file
#authz_default
#authz_user
#autoindex
#cgi
#dir
#env
#negotiation
#userdir
$ sudo mv /etc/httpd/conf.d/autoindex.conf /etc/httpd/conf.d/autoindex.conf.bak # disable autoindex configuration
$ sudo vim /etc/httpd/conf.d/CampaignApache.conf
ErrorLog "logs/error_log_neolane" # custom error file, will be in /var/log/httpd/error_log_neolane because /etc/httpd/conf/logs points to /var/log/httpd
<Directory "/usr/local/neolane/nl6"> # Allow all /nl6/
    Require all granted
</Directory>
LoadModule requesthandler24_module /usr/local/neolane/nl6/lib/libnlsrvmod.so # load acc lib
Include /usr/local/neolane/nl6/tomcat-7/conf/apache_neolane.conf # load tomcat conf
$ sudo vim /usr/local/neolane/nl6/conf/serverConf.xml # find any allowHTTP="false" and replace with
allowHTTP="true"
$ sudo vim /etc/selinux/config # you might to disable SELinux as well, update:
SELINUX=disabled
$ sudo service httpd restart
```

Go ahead and connect to your VM without the `:8080` port, such as `http://10.23.87.90/view/home`:
![](/assets/images/2019/03/adobe-campaign-apache.jpg)

The network is now as follow:
![](/assets/images/2019/03/adobe-campaign-install-architecture-network-with-apache.jpg)

### Allow external PostgreSQL access
Allow external access to postgresql, see https://blog.bigbinary.com/2016/01/23/configure-postgresql-to-allow-remote-connection.html
```console
$ sudo vim /var/lib/pgsql/data/postgresql.conf # replace listen_addresses = 'localhost' to
listen_addresses = '*'
$ sudo vim /var/lib/pgsql/data/pg_hba.conf # add at the end:
host    all             all              0.0.0.0/0                       md5
host    all             all              ::/0                            md5
$ sudo firewall-cmd --zone=public --add-port=5432/udp --permanent
$ sudo firewall-cmd --zone=public --add-port=5432/tcp --permanent
$ sudo firewall-cmd --reload
```
![](/assets/images/2019/02/adobe-campaign-install-sqlectron-connect.jpg)


### 2023 update
- Download: Get VM from osboxes.org > Centos 7.9 (https://www.osboxes.org/centos/)
- Virtualbox: Configure the network to "bridged"
- Virtualbox: Start the VM, login with 'osboxes', password 'osboxes.org' (QWERTY keyboard by default)
- VM: Top right corner > Network > Wired, set to `on`
- VM: Applications > System tools > Terminal > $ ifconfig
- (VM: firewall?)
- Host: ssh-copy-id osboxes@<IP>
- Host: Filezilla > export `rpm` to ~/Downloads
