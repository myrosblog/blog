---
title: Migrate from Wordpress to Jekyll [Part 1/2]
categories: [jekyll, opensource, server]
---

This post is the part 1 of the tutorial collection on how to migrate from Wordpress to Jekyll.
- Part 1. Introduction
- [Part 2. Create the Search component]({% post_url 2018/2018-11-21-migrate-from-wordpress-to-jekyll-2 %})

## Install Jekyll locally
See [the Jekyll homepage](https://jekyllrb.com/)
```bash
$ ruby -v && gem -v # just making sure we got ruby and gem installed
$ gem install bundler jekyll
```
## Publish to github.io
Github can be used to host Jekyll static websites, on username.github.io/repository-name

Just push to a Github repo on the `master` branch, and enable Pages on Gihtub in Settings > GitHub Pages
## Create custom domain with https
2 steps:
1. Activate it in the repo settings, it's going to create a `CNAME` file with your custom domain:

2. Then, in your hosting provider DNS settings (such as [OVH](https://www.ovh.co.uk/domains/)), configure a CNAME DNS entry with your github.io URL:
![todo](/assets/images/2018/11/ovh-dns-blog-myrosblog-com.jpg)

PS: For HTTPS it's [automatic since 2016](https://help.github.com/articles/securing-your-github-pages-site-with-https/), it might take up to a day to propagate. Be sure to enable this option in the repo settings.

## Migrate posts content from Wordpress
I used [https://wordpress.org/plugins/jekyll-exporter/](https://wordpress.org/plugins/jekyll-exporter/).

## Edit Server config for redirects
Posts on old wordpress site were hosted on https://myrosblog.com/2018/01/title-here, but now they are hosted on https://blog.myrosblog.com/2018/01/title-here

A quick Nginx rule did the trick, to ensure backward compatibility:
```nginx
location ~ ^/2018 {
	rewrite ^ https://blog.myrosblog.com$request_uri? permanent;
}
```

## Migrate Wordpress default functionalities
Jekyll comes as a pretty bare and simple blogging plateform. You can create posts and categories, but there's no SEO, no categories browsing or even comments. I had to dig a little deeper to find what I was looking for.

### Add Jekyll SEO
This one is easy and automatic as it comes as a Jekyll plugin. Jekyll plugins are installed by adding an entry in `_config.yml` and `Gemfile`, then running `bundle install`. See [Jekyll SEO install details](https://github.com/jekyll/jekyll-seo-tag/blob/master/docs/installation.md).
### Add categories
This one is a little bit more complicated. Categories in wordpress allow us to browse, search and display posts. This is not a native feature of Jekyll.

First we need a page with all categories. I reused this [very good tutorial on Jekyll categories](https://blog.webjeda.com/jekyll-categories/) where the idea is to have a `/categories.html` with a Jekyll standard loop {% raw %}`{% for category in page.categories %}`{% endraw %}.

I also added this bit at the top and the bottom of each post, in order to display the categories of a post:
![todo](/assets/images/2018/11/wordpress-to-jekyll-categories-display.jpg)
{% raw %}```html
{% for category in page.categories %}
  <a href="{{site.baseurl}}/categories?id={{category|slugize}}"
    class="badge badge-info">
    <i class="fas fa-tag"></i> {{category}}
  </a>
  {% unless forloop.last %}&nbsp;{% endunless %}
{% endfor %}
```{% endraw %}
*See [https://github.com/myrosblog/blog/blob/master/_layouts/post.html](https://github.com/myrosblog/blog/blob/master/_layouts/post.html)*

Noticed the `/categories?id=` part? With a bit of javascript, we are able to display a specific category:
![todo](/assets/images/2018/11/jekyll-display-categories-by-id.jpg)
```javascript
if(location.search.match(/id=([^&]*)/i)){
  var hash = location.search.match(/id=([^&]*)/i)[1].replace(/%20/g, ' ');
  var categories = document.getElementsByClassName('category');
  for(var category of categories){
    if(category.id != hash){
      category.className += ' d-none'; // d-none is the bootstrap 4 class to hide an element
    };
  }
}
```
*See [https://github.com/myrosblog/blog/blob/master/categories.html](https://github.com/myrosblog/blog/blob/master/categories.html)*

### Add Previous/Next
`_layouts/post.html`
{% raw %}```html
<!-- Previous post -->
{% if page.previous %}
    {% assign previous = page.previous %}
{% else %}
    {% assign previous = site.posts[0] %}
{% endif %}
<a href="{{site.baseurl}}{{previous.url}}">{{previous.title}}</a>

<!-- Next post -->
{% if page.next %}
    {% assign next = page.next %}
{% else %}
    {% assign last lastPostIndex = site.posts | size | minus: 1 %}
    {% assign next = site.posts[lastPostIndex] %}
{% endif %}
<a href="{{site.baseurl}}{{next.url}}">{{next.title}}</a>
```{% endraw %}
*See [https://stackoverflow.com/questions/29932644/looping-previous-and-next-post-in-jekyll](https://stackoverflow.com/questions/29932644/looping-previous-and-next-post-in-jekyll)*
### Add comments
Disqus
### Add robots.txt
`/robots.txt`
```
---
---
# www.robotstxt.org/
User-agent: *
Sitemap: {{ site.url }}/sitemap.xml
```
*See [https://github.com/myrosblog/blog/blob/master/robotx.txt](https://github.com/myrosblog/blog/blob/master/robotx.txt)*

### Add the "Improve this page" link
```html
<a href="https://github.com/myrosblog/blog/edit/master/{{ page.path }}" target="_blank">Improve this page</a>
```

## Migrate HTML to Markdown
Headers
```
Find:     [ \t]*<h2>\s*([\w  \-]+)\s*</h2>
Replace:  ## $1
Find:     [ \t]*<h3>\s*([\w  \-]+)\s*</h3>
Replace:  ### $1
```

Links (URL regex from https://www.regexpal.com/94502)
```
Find:     <a .*href="([\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+?)".*>(.+?)</a>
Replace:  [$2]($1)
```

## Migrate Crayon Code Highlighter
Regex for code blocks:
```
Find:    [ \t]*<pre class="lang:(\w+) decode:true ?">(.*)\n
Replace: ```$1\n$2

Find:    \n?</pre>
Replace: \n```

Find:    <span class="lang:\w+ decode:true crayon-inline">([/\w\.\-><$]+)</span>
Replace: `$1`

Find:    (&#8216;|&#8217;|&#8220;|&#8221;)
Replace: '

Find:    &lt;
Replace: <

Find:    &gt;
Replace: >
```


## Migrate images
Regex for jetpack optimised images:
~~~
Find:    <img.*src=".+wp-content/uploads(.+)\?.+".*/>
Replace: ![todo](/assets/images$1)
~~~

## Customization
### Add Bootstrap 4

## Pros and Cons
Jekyll on Github compared to Wordpress is:
- **faster:** no database access, no programming language, only raw html and images
- **cheaper:** you only pay for the domain name (~$10/year) instead of paying for a VPS $5/mo
- **safer:** no login or admin backoffice, no field and no form, no .htaccess and not on-premise so there's 0 security flaw
- **highly customizable:** without being too complex to edit, Jekyll offers a quick way to extend its functionnalities
- **not bloated:** I got sick of WP because of 5-10 sec page loads.. A quick look at the HTML source and some Lighthouse audits reveal a lot of useless JS+CSS
- **bootstrap friendly:** most of the WP themes will break when used with BS. As Jekyll is built with simplicity in mind, adding BS will keep everything in order. This way, components (alert, popover, icons...) and utilities (grid, show/hide...) are available
- **focused on content:** with Markdown (`.md`) based files, Jekyll focuses on content rather than on markup. It relies on much cleaner a source

But on the other hand, Wordpress is better for:
- the setup: WP can be set up in 5-10 min, instead of 1-2 days for an extended Jekyll website
- plugins: which are the reason of the bloat.. But for GA, GTM, SEO, RSS, code highlighting, etc. WP has some first-class and easy-to-install plugins, comparent to Jekyll where there's a need of writing raw HTML/Liquid
- the ecosystem and the community: WP has more experience, runs on more websites and has many big brands support
- private drafts: drafts are open source on Jekyll, which is a pain in the a**
- Images management: WP is really easy to use for images
