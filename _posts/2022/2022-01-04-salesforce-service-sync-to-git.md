---
title: Salesforce Service Cloud synchronization to Git repository
categories: [salesforce,git,opensource]
---

<p class="text-center">🌩️🔛🐙</p>

<!--more-->

## Overview

## Architecture

## Instructions

### Prerequisites

- Basic linux knowledge (check [LINUX cheatshet](/2018/12/unix-cheatsheet) for help)
- Basic Salesforce knowledge (check [Apex cheatsheet](2021/06/salesforce-apex-cheatsheet) for help)
- SFSC instance
- SFSC User granted with permissions: ModifyMetadata (otherwise INSUFFICIENT_ACCESS error), Author Apex (otherwise "Entity type 'ApexClass' is not available in this organization" error)
- Github.com account
- Basic git knowledge

### Setup from Personal PC

- From browser, create an empty Git repo "myinstance-repo"
- From ~/

```console
$ sfdx force:auth:web:login -r https://test.salesforce.com # authorize Org
Successfully authorized myinstance_username with org ID 00xxxxxxXXXxx
$ git clone git-username@myinstance-repo # pull git repo
$ sfdx force:project:create -n myinstance-repo # init sf project into repo
$ cd myinstance-repo && git status
$ mkdir manifest
$ vim manifest/package.xml # create package
get from https://myrosblog.com/2021/10/salesforce-retrieve-all-code-from-org
$ git add . && git commit -m "sfdx project" && git push
$ sfdx force:org:display -u myinstance_username --verbose --json
{
  "status": 0,
  "result": {
    "id": "00 [...]
}
```

### Setup for automatic backups from headless VM

From ~/
```console
$ vim authFile.json
paste JSON data from Personal PC
$ export SFDX_USE_GENERIC_UNIX_KEYCHAIN=true # to bypass SFDX usage of gnome-keyring (errors: X11 $DISPLAY, secret-tool org.freedesktop.Secret.Error.IsLocked)
$ sfdx force:auth:sfdxurl:store -f authFile.json
Successfully authorized myinstance_username with org ID 00xxxXXXXXxxXXXX
$ rm authFile.json
$ git clone git-username@myinstance-repo
$ cd myinstance-repo
$ sfdx force:source:retrieve -u myinstance_username -x manifest/package.xml
$ git add . && git commit -m "package" && git push
```

### Multi-instance setup
```console
~/
  .sfdx/
    alias.json
    instance1_preprod.json
    instance1_prod.json
    instance2_preprod.json
    instance2_prod.json
  instance1-preprod/
    .git/ connected to repo1 @ preprod
    force-app/
  instance1-prod/
    .git/ connected to repo1 @ main
    force-app/
  instance2-preprod/
    .git/ connected to repo2 @ preprod
    force-app/
  instance2-prod/
    .git/ connected to repo2 @ main
    force-app/
```

### Make it recurrent with CRON jobs

```console
$ vim cronjobs.bash
#!/bin/bash
export SFDX_USE_GENERIC_UNIX_KEYCHAIN=true
githubToken="insert_your_github_token"

case $1 in
    instance1-preprod)
        cd ~/instance1-preprod && ~/sfdx/bin/sfdx force:source:retrieve -u user1@instance1-preprod -x manifest/package.xml && git add . && git commit -m "$(date +%Y-%m-%d_%H:%M:%S)" && git push https://$githubToken@github.com/MY_ORG/INSTANCE1
    ;;
    instance1-prod)
        cd ~/instance1-prod && ~/sfdx/bin/sfdx force:source:retrieve -u user1@instance1-prod -x manifest/package.xml && git add . && git commit -m "$(date +%Y-%m-%d_%H:%M:%S)" && git push https://$githubToken@github.com/MY_ORG/INSTANCE1
    ;;
$ chmod +x cronjobs.bash
$ ./cronjobs.bash instance1-preprod # test
$ crontab -e
20 * * * * ~/cronjobs.bash instance1-preprod
25 * * * * ~/cronjobs.bash instance1-prod
```

This will automatically generates commits like `2022-12-27_16:30:07` for both preprod & prod.
