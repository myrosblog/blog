---
title: Sync Adobe Campaign to Git every hour and track Schemas, Forms & more!
categories: [git,backup,sync,opensource,adobe campaign]
---
Set up a small software in a VM (or your own PC) to backup your Adobe instances (dev & prod) to your Git repos!
<p class="text-center">📂🔄⚛️</p>
<!--more-->

## Track your instance via a Git Repo


### Explore Files and Folders via a web UI
![](https://raw.githubusercontent.com/myrosblog/adobe-campaign-sync/master/doc/Instance%20git%20repo%20-%20schemas.jpg)

### Track the smallest change via Git Diff
![](https://raw.githubusercontent.com/myrosblog/adobe-campaign-sync/master/doc/Instance%20git%20repo%20-%20difference.jpg)

## Architecture
![](https://raw.githubusercontent.com/myrosblog/adobe-campaign-sync/master/doc/Presentation.jpg)

## Instructions

### Prerequisites
- Basic linux knowledge (check [LINUX cheatshet](/2018/12/unix-cheatsheet) for help)
- Basic Adobe Campaign knowledge (check [Awesome Adobe Campaign](/awesome-adobe-campaign)) for help)
- Adobe Campaign Classic instance with admin username
- Github.com account
- Basic git knowledge
- Environment with NodeJS installed (local computer or VM)

### Setup

Example from Linux VM environment:

```bash
$ pwd # /home/user
$ git clone https://github.com/myrosblog/adobe-campaign-sync myinstance-prod # 1 folder per instance
$ cd myinstance-prod
# if behind a corporate firewall, set HTTP proxy
$ npm config set proxy http://x.x.x.x:port
$ npm config set https-proxy http://x.x.x.x:port
# install dependencies
$ npm install
```

### Launch

```bash
# note: clone with a GIT url, not an HTPPS, otherwise SSH autologin with the SSH public key won't work
$ git clone git@github.com/user/instance1.git instance
# copy env file, and edit it
$ cp .env.dist .env
$ vim .env
$ node src/download.js # download data schemas
$ cd instance && git status # check
$ git add . && git commit -m "$(date +%Y-%m-%d_%H:%M:%S)" && git push
```

That's it! Set up a CRON every 15 min:

```bash
$ crontab -e
*/15 * * * * cd ~/myinstance-prod && node src/download.js && cd instance && git add . && git commit -m "$(date +%Y-%m-%d_%H:%M:%S)" && git push
```

Source code on [github.com/myrosblog/adobe-campaign-sync](https://github.com/myrosblog/adobe-campaign-sync)

### Multi-instance setup

```console
~/
  adobe-campaign-sync/
  instance1-preprod/
    .env
    instance/
      .git/ connected to repo1 @ preprod
  instance1-prod/
    .env
    instance/
      .git/ connected to repo1 @ main
  instance2-preprod/
    .env
    instance/
      .git/ connected to repo2 @ preprod
  instance2-prod/
    .env
    instance/
      .git/ connected to repo2 @ main
```
