---
title: UNIX cheatsheet
categories: [opensource,bash,shell,unix]
---

Cheatsheet with filesystem, commands and common utilities for UNIX based systems (Linux, Mac).

<!--more-->

## UNIX filesystem
```bash
/bin # essential user binaries
  bash, cat, cp, grep, ls, nano, touch, tar, uname
/dev # devices
  null # to redirect unwanted stdout
/etc # config files (text based, so easily editable)
  crontab, hosts, init.d, passwd, timezone
/home # home folders for users
/lib # shared C libraries
/mnt # "mounted" drives
/opt # other softwares. Not binaries as there's 1 folder per software (with config, bin, lib, etc). Like Program Files on Windows.
/root # home folder for user "root"
/sbin # "system binaries"
  fdisk, fsck, init, reboot
/tmp # temp folder, gets emptied at reboot
/usr # "users",
  bin/ games/ lib/ local/ sbin/
/var # "variable", folder for files that change often
  log/ mail/ www/
```
See [wikipedia Unix_filesystem](https://en.wikipedia.org/wiki/Unix_filesystem)

## Evolution UNIX and UNIX-like systems
<div class="">
  <a href="https://upload.wikimedia.org/wikipedia/commons/7/77/Unix_history-simple.svg" target="_blank">
    <img src="https://upload.wikimedia.org/wikipedia/commons/7/77/Unix_history-simple.svg" style="max-height:150px" class="no-lightgallery"/>
  </a>
</div>

## Linux distributions timeline hierarchy (SVG)
<div class="">
  <a href="https://upload.wikimedia.org/wikipedia/commons/1/1b/Linux_Distribution_Timeline.svg" target="_blank">
    <img src="https://upload.wikimedia.org/wikipedia/commons/1/1b/Linux_Distribution_Timeline.svg" style="max-height:150px" class="no-lightgallery"/>
  </a>
</div>

## Bash basics

### Bash architecture

<div>
  <img src="https://developer.ibm.com/developer/tutorials/l-linux-shells/images/figure1.gif" style="max-height:150px"/>
</div>
<div>
  <img src="https://developer.ibm.com/developer/tutorials/l-linux-shells/images/figure2.gif" style="max-height:150px"/>
</div>

Source on [IBM developers](https://developer.ibm.com/tutorials/l-linux-shells/)

### Bash main commands
```bash
id # Identification, displays current user (and uid), main group (and guid) and other groups (with guid)
who -H # Who is logged in, with h=column Headers
pwd # Print Working Dir
ls -alh # list a=All (even hidden .) as a l=List in a h=Human-readable format
ls -ld /usr/{,local/}{bin,sbin,lib} # ls only dir with Shell Expansion
mkdir {2019..2021}-0{1..9} {2019..2021}-{10..12} # Shell expansion with numbers
mkdir -p /opt/dirA/diB # recursive
mktemp # create a file and print its name, relative to $TMPDIR if set, else /tmp
mktemp -d # create a directory
printenv | less # print env vars
ls -l $(which python) # command substitution with $(cmd-here)
passwd # update password for current user
sudo passwd user_name # update password for user_name
find . -name filename_here # find filename
find /path -type f -mtime -7 # find files modified in the last 7 days
wc file.txt # display count of: lines words bytes
wc -l file.txt # display only lines count. And -w for words, -m for characters, -c for bytes
wc -L file.txt # display length of longest line
shutdown -P # power off (default)
shutdown -r # reboot
shutdown -c # cancel shutdown
```
[man id](https://linux.die.net/man/1/id), [man who](https://linux.die.net/man/1/who), [man ls](https://linux.die.net/man/1/ls)

### Bash IO

```bash
echo -e "hello\n$(cat file)" > file # prepend to file
echo "hello" >> file # append to file
wget https://myfile.com -O output # save a web file to disk
```
[man echo](https://linux.die.net/man/1/echo), [man wget](https://linux.die.net/man/1/wget)

```bash
ls -l > file # stdout 2 file
ls -l > file # stderr 2 file
ls -l 1>&2 # stdout 2 stderr
ls -l 2>&1 # stderr 2 stdout
ls -l &> file # both stdout and stderr 2 file
ls -l &> /dev/null # totally wipes output (i.e for silent CRON)

echo $? # last return code. 0 is success, 126 is found but not executable, 127 is not found, any non-zero integer is failure
```
[TLDP redirection](http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-3.html), [wiki exit status](https://en.wikipedia.org/wiki/Exit_status)

### Bash loops

```bash
# Run a command every 2 minutes
while true; do echo "$(date)"; command; sleep 120; done
# Iterate over files in a directory:
for file in /path/*; do echo "$file"; done
# Process each line in a file:
while read line; do echo "$line"; done < file.txt
```

### Bash file

```bash
$ vim myfile
#!/bin/bash
case $1 in
    login)
        echo "Logged in"
        ;;
    *)  echo "Incorrect command"
        ;;
esac
```

```console
$ ./myfile login
Logged in
```

## Bash for DNS

With `dig` and `whois`

```bash
# list DNS records
$ dig jsonplaceholder.typicode.com
jsonplaceholder.typicode.com. 240 IN    A       172.67.167.151
jsonplaceholder.typicode.com. 240 IN    A       104.21.59.19

$ whois jsonplaceholder.typicode.com
contact:      administrative
name:         Registry Customer Service
organisation: VeriSign Global Registry Services
[...]
>>> Last update of whois database: 2026-02-10T02:05:47Z <<<
```

## UNIX man
The UNIX manual is divised into 10 sections:
- [Section 1](https://linux.die.net/man/1/): user commands
- [Section 2](https://linux.die.net/man/2/): system calls
- [Section 3](https://linux.die.net/man/3/): C library functions
- [Section 4](https://linux.die.net/man/4/): special files
- [Section 5](https://linux.die.net/man/5/): file formats
- [Section 6](https://linux.die.net/man/6/): games
- [Section 7](https://linux.die.net/man/7/): conventions and miscellany
- [Section 8](https://linux.die.net/man/8/): administration and privileged commands
- [Section L](https://linux.die.net/man/l/): math library functions
- [Section N](https://linux.die.net/man/n/): tcl functions

The online version is available on [https://linux.die.net/man/{section id}/{name}](https://linux.die.net/man/). Usually, pages can be accessed with the section number and the name of the tool/function/page. For example, the man page for `strtod(3)` is available online at [https://linux.die.net/man/3/strtod](https://linux.die.net/man/3/strtod).

## macOS

```bash
$ xcode-select --install # 2.72 Gb
$ softwareupdate -l # list updates from Software Update Tool
$ defaults write com.apple.finder AppleShowAllFiles YES; killall Finder # show hidden files
$ system_profiler # View system information
```

Disable SIP (System Integrity Protection) [Doc on developer.apple.com](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection)
- Restart in Recovery mode with Command-R during startup
- Open Terminal:

```bash
csrutil disable
```

## CRON

```console
$ crontab -l # list
$ crontab -e # edit
# tail -f /var/log/cron
```
CRON examples
```bash
# comment
05 * * * * cd ~/abc && node src/download.js
# MINUTE(0-59) HOUR(0-24) DAY(1-31) MONTH(1-12) WEEKDAY(Sunday 0 to Saturday 6)
```

## IP

IPs with CIDR notation. [Compute CIDR notation with online tool](https://ipaddressguide.com/cidr)
- `/32` = 1 IP range (mask 255.255.255.255): `1.1.1.1/32` = range from `1.1.1.1` to `1.1.1.1`
- `/24` = 256 IP range (mask 255.255.255.0): `1.1.1.1/24` = range from `1.1.1.0` to `1.1.1.255`
- `/22` = 1,024 (4 * 256) IP range (mask 255.255.252.0): `1.1.1.1/22` = range from `1.1.0.0` to `1.1.3.255`

## curl
```bash
curl site.com # protocol defaulted to http
curl site.com/basic-auth --user user1:plainPassword1 # Basic auth
curl ftp://site.com -u FTP_USERNAME:FTP_PASSWORD # list directories and files via FTP
curl ftp://site.com/file -u FTP_USERNAME:FTP_PASSWORD # download file via FTP
curl ftp://site.com/ -T file -u FTP_USERNAME:FTP_PASSWORD # upload file via FTP
curl site.com -I # dump response headers
curl site.com -v # verbose mode to show IP, port, Request and Reponse headers..
curl site.com -H "Referer:a.com" -H "Content-Type:application/json" -H "User-Agent:..." # set headers
curl site.com --raw # raw and undecoded version of the response
curl site.com -s # --silent version, no output
curl site.com -L # --location, follow redirects
curl site.com/form -d "key1=val1&var2=love%20you" # --data POST for form, automatically set the header "Content-type:application/x-www-form-urlencoded"
curl site.com/form --data-urlencode "key1=val1&var2=love you" # automatic url encode
curl google.{fr,com,de} # fetch multiple URLs at once with {syntax}
curl numericals.com/file[1-100].txt # fetch from 1 to 100 with [] syntax
curl numericals.com/file[1-100:10].txt # same with counter step set to 10 => 1, 11, 21...
curl letters.com/file[a-z:2].txt # fetch letters from a to z with step set to 2
```

## grep (find in file and files)

```bash
grep 'word' file1 file2
grep -w 'word_only' file1 file2
grep -r 'word' dir
grep -n file-with-line-numbers
grep -A 1 file # next lines, -B 1 previous lines, -C both lines
grep -e '^[A-C]' file # regex
```

[man grep](https://linux.die.net/man/1/grep)

## vi/vim
```bash
vimtutor # vim tutorials
i # insert mode
w # write (save)
q # quit
wq # save & quit
q! # force quit without saving
/ # find
n # repeat find (next occurence)
1G # go to line 1
99G # go to line 99
G # go to end of file
```

## process & pid
```bash
pidof vscode # 123 456 789
ps aux | grep vscode # 
pgrep vscode
kill -[signal] PID
kill -SIGTERM 123
killall -15 vscode
```

## Encode & decode
```bash
echo 'I-love-you' | base64 # base64 encode (SS1sb3ZlLXlvdQo=)
echo 'SS1sb3ZlLXlvdQ==' | base64 -d # base64 decode (I-love-you)
```

## PATH & softwares

`/usr/local/bin` to install any bin shared amongst users on the local machine

```bash
bash -c 'echo $PATH'
```
```terminal
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games # for Linux
/usr/local/bin /usr/bin /bin /usr/sbin /sbin # for Mac
```

## Symbolic links - symlinks

```bash
ln -s source target
ln -s ~/my_executable /usr/local/bin/my_executable # to add a binary to PATH
```

## TAR

```bash
tar cvf test.tar .# TAR current dir: c=create, v=verbose, f=file
tar tvf test.tar # list content of TAR file: t=table of content
tar xvf test.tar # unTAR all files: x=xtract
tar xvf test.tar file1 # unTAR specific file
```

## GZIP

ZIP format archives and compresses files and folders. >> Popular on Windows
GZIP format compresses 1 file. To compress multiple files with GZIP, they have to be archived into a single TAR file (called tarball). Hence .tar.gz. >> Popular on UNIX
```bash
gzip file1 # GZIP file1 to file1.gz (and delete file1)
gzip -k file1 # GZIP file1 to file1.gz and keep file1
gzip -r dir # GZIP all files in dir
gzip -d file1 # Decompress GZIP file
```

## 7zip

```bash
7z l file.zip # List content of zip
7z l -slt file.zip # slow technical information of zip
```

## ZIP & UNZIP

```bash
zip file.zip file1 file2
unzip file.zip # Unzip in current dir
unzip file.zip -d /target # Unzip in /target dir
unzip -l file.zip # List content of zip
unzip -t file.zip # Test if valid zip
unzip -v file.zip # Display information such as Length, Method, CRC-32...
unzip -j file.zip # Unzip without directory structure (flat)
unzip -P plain_password file.zip # Unzip with plain text password
unzip -q file.zip # Unzip with quietly (no output)
```

[man zip](https://linux.die.net/man/1/zip),
[man unzip](https://linux.die.net/man/1/unzip)

## SSH

Generate a key pair
```console
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (~/.ssh/id_rsa):
[...]
```

Compute the RSA key fingerprint
```console
$  ssh-keygen -lf .ssh/id_rsa.pub
2048 SHA256:XXXXAAXXX user@machine (RSA)
```

Connect from client to host
```console
$ ssh user@host
```

Copy SSH key from client to host
```console
$ ssh-copy-id user@host
```

## Distributions

### Debian / Ubuntu

- Debian Names coming from [Toy story characters](https://www.debian.org/doc/manuals/debian-faq/ch-ftparchives#s-sourceforcodenames). Debian 9 (stretch 2017), Debian 8 (jessie 2015), Debian 7 (wheezy, 2013)

As root:
```console
apt update # check for new versions
apt upgrade # install new versions
apt install git
```

### Red Hat Enterprise Edition (RHEL) / Fedora / CentOS

As root:
```bash
dnf check-update # check for new versions
dnf upgrade # install new versions
dnf list --all # list installed

dnf info git
dnf install git
dnf remove git
```

## Database

### SQL

```sql
CREATE TABLE items (
    id INT PRIMARY KEY,
    price DECIMAL(10,2),
    quantity FLOAT,
    name VARCHAR(255),
    description TEXT,
    launch_date DATE,
    created_at TIMESTAMP,
    is_active BOOLEAN,
    status ENUM('Active', 'Inactive', 'Pending')
)
```

## Programming languages

todo https://jsonplaceholder.typicode.com/users

### C via gcc (Gnu C Compiler)

```c
#include <stdio.h>
int main() {
    char userInput[100];
    printf("Enter a string: ");
    scanf("%99s", userInput);
    printf("You entered: %s\n", userInput);
    return 0;
}
```

```bash
gcc -v # print version "gcc version 9.3.0 (Ubuntu 9.3.0-17ubuntu1~20.04)"
gcc file1.c file2.c -O mybinary # compile to mybinary
gcc -Wall file1.c file2.c -O bin # add -Wall to print all warnings
```

### PHP and composer

```bash
php -v # PHP version (5.6, 7.2...)
php -a # REPL interactive shell (exit with exit)
php -c php.ini # use this config file
php -n # use no config file
php -f file # parse and execute file
php -r "echo 'test';" # execute PHP code without tags <? .. ?>
php -i # displays phpinfo() for CLI
php -S localhost:8000 -t web/ app.php # start the PHP built-in web server in the folder web/ with every requests sent to web/app.php on port 8000
composer --version # 1.6
composer require guzzlehttp/guzzle # install the guzzle package, public list on https://packagist.org/
composer install # install deps from composer.lock
composer exec phpunit # execute a bin from vendor/bin/
```

### Python and pip

```bash
python --version # Python version (2.7, 3.2...)
python # REPL interactive shell (exit with exit())
python -c 'import os; print(os.urandom(16))' # execute code
pip install requests # install module requests
python2 -m SimpleHTTPServer # basic HTTP server. Serve static files from current dir
python3 -m http.server 8000 # basic HTTP server. Serve static files from current dir
```

```python
class Car:
    def __init__(self, id, name, is_available):
        self.id = id
        self.name = name
        self.is_available = is_available
    def __str__(self):
        return f"Name: {self.name}, Id: {self.id}, Available: {self.is_available}"
class Main:
    def __init__(self):
        countries = ["France", "USA", "Spain"]
        countries.append("Italy")
        available_cars = [car for car in all_cars if car.is_available and car.name in countries]

        try:
            my_car = next(car for car in available_cars if car.id == 999)
        except StopIteration:
            my_car = Car(-1, "xxx", True)  # Correcting the type to String
        finally:
            for car in available_cars:
                print(car)
if __name__ == "__main__":
    Main()
```

### Ruby, Gem and Jekyll

```bash
ruby -v # Ruby version (2.2, 2.5...)
gem -v # Gem version (2.7..)
gem install bundler # install the bundler gem, public list on https://rubygems.org/gems
jekyll doctor # checks modules and config
jekyll build # one time build of ./site
jekyll serve # starts local server
```

### NodeJS and npm

```bash
node -v # nodejs version (8.x, 10.x...)
node -e "var a=1" # execute JS code
node -p "var a=1" # execute JS code and print result
node # REPL interactive shell (exit with .exit)
npm -v # 5.x
npm install package-x
sudo rm -rf /usr/local/bin/npm /usr/local/share/man/man1/node* /usr/local/lib/dtrace/node.d ~/.npm ~/.node-gyp # uninstall
```

Note: for a dev machine (single user, multiple node versions) don't install node/npm as root, use [nvm - Node Version Manager](https://github.com/nvm-sh/nvm) instead. More in this [Medium post](https://medium.com/@ExplosionPills/dont-use-sudo-with-npm-still-66e609f5f92)

```javascript
class Car {
    constructor(id, name, isAvailable) {
        this.id = id; this.name = name; this.isAvailable = isAvailable;
    }
    toString() { return `Name: ${this.name}, Id: ${this.id}, Available: ${this.isAvailable}`; }
}

class Main {
    constructor() {
        let countries = ["France", "USA", "Spain"];
        const allCars = this.getCars(); // Assuming you have a method to get all cars
        countries.add("Italy");
        const availableCars = allCars.filter(x => x.isAvailable && countries.includes(x.name));
        let myCar;
        try {
            myCar = availableCars.find(x => x.id === 999);
        } catch (e) {
            myCar = new Car("xxx");
        } finally {
            availableCars.forEach(car => {
                console.log(car.toString());
            });
        }
    }
}

new Main();

```

### Java

```bash
java -version
javac -cp . *.java # compile to .class files
java -cp . MyClass # run the MyClass class, based on .class files
javac -classpath classes src/*.java -d classes/ && java -cp classes/ com.namespace.MyApp # one-shot build & run
jar -cf myJar.jar classes/ # create JAR
java -jar MyJar.jar # execute JAR Main-Class defined in MANIFEST.MF
java -cp MyJar.jar com.namespace.ClassWithMainMethod
```

Note: `MyClass` should contain the `main` method:

```java
package fco;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

class Car {
    private int id; private String name; private boolean isAvailable;
    public Car(int id, String name, boolean isAvailable) {
        this.id = id; this.name = name; this.isAvailable = isAvailable;
    }
    @Override
    public String toString() {
        return String.format("Name: %s, Id: %d, Available: %b", name, id, isAvailable);
    }
}

public class Main {
    public Main() {
        List<String> countries = List.of("France", "USA", "Spain");
        countries.add("Italy");
        List<Car> availableCars = new ArrayList<>();
        for (Car car : getCars()) {
            if (car.isAvailable && countries.contains(car.getName())) {
                availableCars.add(car);
            }
        }

        Car myCar;
        try {
            myCar = availableCars.stream().filter(x -> x.getId() == 999).findFirst().orElse(null);
        } catch (Exception e) {
            myCar = new Car(-1, "xxx", true); // Correcting the type to String
        } finally {
            for (Car car : availableCars) {
                System.out.println(car);
            }
        }
    }

    public static void main(String[] args) {
        new Main();
    }
}

```

### Csharp, C#, Unity

```csharp
using System.Linq; // Where, Find
using System.Collections.Generic; // List

namespace fco {
  public class Main {
    public Main() {
      List<string> countries = new List<string> {"France", "USA", "Spain"};
      names.Add("Italy");
      List<Car> availableCars = allCars.Where(x => x.isAvailable && countries.Contains(x.name)); // Lambda
      Car myCar;
      try {
          myCar = availableCar.Find(x => x.id == 999);
      } catch (Exception e){
          myCar = new Car{
              id = 123
          };
      } finally {
        foreach(Car car in availableCars){
          Console.WriteLine(car);
        }
      }
    }
  }
  public class Car {
    public bool isAvailable { get; set; }
    public int id { get; set; }
    public override string ToString(){ return $"Name {Name}, Id {Age}"; }
  }
}  
```

## Infra languages

### Git

```bash
git init
git clone <repo> [<dir>]
git status
git diff
git fetch # see remote changes
git pull # apply remote changes
git add . # add local changes to next commit
git commit -m 'commit msg' # create commit
git branch <branch> # create a branch
git checkout <branch> # switch to branch
git branch -d <branch> # delete a branch
git tag <tag name> # create a tag for current commit
git remote -v # list remotes
git remote add <remote name> <repo url> # add remote
git remote rm <remote name> # delete remote
git config --list --show-origin
git reset --hard <commit sha> # revert to commit
git push -f # force push
```

### Docker
```bash
docker pull ubuntu # download images from hub.docker.com: alpine, mysql...
docker image # list images
docker run --name myubuntu -it ubuntu /bin/bash
root@xxxxxxx:/# exit
docker ps --all # list containers
docker start myubuntu
docker build . # build using local Dockerfile
docker-compose build # build using local docker-compose.yml
docker-compose up -d # run
```
