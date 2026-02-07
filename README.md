# Repository for Jekyll on Github website https://myrosblog.com

[![](https://travis-ci.com/floriancourgey/blog.svg?branch=master)](https://travis-ci.com/floriancourgey/blog)
[![StackShare](https://img.shields.io/badge/tech-stack-0690fa.svg?style=flat)](https://stackshare.io/floriancourgey/blog)

## Install & run (docker)

### 🐳 Install (docker)
```console
$ docker-compose up # Server address: http://127.0.0.1:4000/
# docker exec bash
```

### 💻 Install (local)
```console
$ brew install chruby ruby-install
$ ruby-install ruby 2.7.4 # from https://pages.github.com/versions/
```

### 🚀 Run
```console
$ bundle install
$ bundle exec jekyll serve
```

## Create a post
```bash
$ touch _posts/YYYY-mm-dd-slug-here.md
```

```markdown
---
title: New article
categories: [prestashop,google,opensource,adobe campaign]
---
Excerpt here...
<p class="text-center">🐍👑🌍</p>
<!--more-->
**bold** *italic*  ~~strikethrough~~
## Use h2 for each section
![todo](/assets/images/2019/01/image.png)
```

Video:
```html
<div class="text-center">
  <video autoplay loop muted playsinline height="250">
    <source src="/assets/images/2018/12/overthewire-natas12-php-injection.mp4" type="video/mp4" />
  </video>
</div>
```

Markdown reference
[https://guides.github.com/features/mastering-markdown/#examples](https://guides.github.com/features/mastering-markdown/#examples)

## Update Algolia index
```bash
$ echo 'my_algolia_key' > _algolia_api_key
$ bundle install --gemfile=Gemfile.dev
$ bundle exec jekyll algolia
```

## htmlproofer
```bash
$ htmlproofer --allow_hash_href --empty_alt_ignore --assume_extension --disable_external ./_site &> h
tmlproofer/htmlproofer.log
```
