---
title: Modern web development in Adobe Campaign
redirect_from: /2018/08/modern-web-development-in-adobe-campaign/
categories: [adobe campaign, https, javascript, neolane, opensource]
---

Adobe Campaign documentation is great to build 2-3 web apps. But it's absolutely not scalable in case you need to develop 25-30 web apps with a lot of assets (CSS, JS, Images). Here are some best practices for web development in AC7.

<!--more-->

## Use Bootstrap

For every web apps you'll ever use, use the following boiler plate code:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Title -->
    <title>Subscription</title>
    <!-- favicon -->
    <link href="<%= getOption('RESOURCES_URL') %>favicon.ico" rel="icon"><!-- see next chapter for 'RESOURCES_URL' -->
    <link href="<%= getOption('RESOURCES_URL') %>favicon.ico" rel="shortcut icon"/> 
    <link href="<%= getOption('RESOURCES_URL') %>favicon.png" rel="shortcut icon" type="image/png"/>
    <!-- Common CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= getOption('RESOURCES_URL') %>base.css"><!-- see next chapter for 'RESOURCES_URL' -->
    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%= getOption('RESOURCES_URL') %>my-layout.css">
    <style type="text/css" media="all">
      /* always keep an inline <style> for quick edit by designers */
    </style>
  </head>

  <body class="container"><!-- or .container-fluid, see https://getbootstrap.com/docs/3.3/css/#overview-container -->
    <!-- Common JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/js/bootstrap.min.js" type="text/javascript"></script>
    <link rel="stylesheet" href="<%= getOption('RESOURCES_URL') %>base.js">
    <link rel="stylesheet" href="<%= getOption('RESOURCES_URL') %>google-analytics.js">
    <!-- Custom JS -->
    <link rel="stylesheet" href="<%= getOption('RESOURCES_URL') %>my-page.js">
  </body>
</html>
```

In short you have the following:

- Use modern HTML template from <a href="https://getbootstrap.com/docs/3.3/getting-started/#template">https://getbootstrap.com/docs/3.3/getting-started/#template</a>
- Always separate you common assets (common to all web apps), from the custom assets (on a per case basis)
- Don't include jQuery as it will be automatically added by Adobe Campaign itself. Adobe Campaign 7 will by default import:
  - `jQuery 1.9.1`. Note: jQuery is available via `jQuery` and not with `$`.
  - `jQuery-migrate 1.1.1`
  - `spin.js 2.3.2`
  - `JSON2 polyfill`
- A Google analytics easy set up, to capture traffic
- Use a global option for the Adobe Campaign Resources CDN, see <a href="/2018/08/modern-web-development-in-adobe-campaign/#a-create-a-global-option-resource_url">below</a>

## Organize your assets

### Create a global option RESOURCE_URL

Adobe Campaign gives us the ability to get the Online Resources URL in JavaScript with `xtk.fileRes.GetPublicFileResURL()`. Call it in a workflow or get it from a Resource:

![](/assets/images/2018/08/File-Resource-CDN-URL-in-Adobe-Campaign.jpg)

Replace `http` by `https` and use it in an Option:

![](/assets/images/2018/08/RESOURCE_URL-Option-with-HTTPs-URL.jpg)

### Use filename instead of md5

By default, every File Resource will be given a Public URL based on it's md5 content:

![](/assets/images/2018/08/File-Resource-URL-in-as-md5-hash.jpg)

This is absolutely not what we want. If you change the image, the md5 will change as well, so you'll have to change it in **all** your webapps&#8230; Which means for every CSS change, you'd have to edit the Public URL 😵.

Instead, we can ask Adobe Campaign to use the Filename in place of the md5 hash. Uncheck the checkbox in the advanced parameters of the resource:

![](/assets/images/2018/08/File-Resource-URL-as-filename-instead-of-md5-hash.jpg)

### Enjoy

This way, we just made Web development in AC great again!

```html
<!-- CSS -->
<link rel="stylesheet" href="<%= getOption('RESOURCES_URL') %>style.css">
<!-- JS -->
<script src="<%= getOption('RESOURCES_URL') %>script.js" type="text/javascript"></script>
<!-- Image -->
<img src="<%= getOption('RESOURCES_URL') %>loader.svg"/>
```

And with this new markup, you are able to *migrate very easily* from your *Staging/Dev Environment to your Production Environment*. We're now [#DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) compliant. Sweeeeet 🍡🍭🍬

## Sharing meta data (Facebook opengraph og, Twitter card, Google result)

Ever tried to share a web app in Facebook?

Update your workflow by adding a JavaScript activity right before the first page:

![](/assets/images/2018/08/Set-sharing-meta-data-for-modern-development.jpg)

Use this JS code:

```js
ctx.sharing.title = "Title for Social Media"
ctx.sharing.author = "Author"
ctx.sharing.description = "Social description"
ctx.sharing.image = "https://Public image URL used for sharing"
```

and in your HTML:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    [...]
    <!-- Title -->
    <title>Subscription</title>
    <!-- meta For Google -->
    <meta name="description" content="<%= ctx.sharing.description %>" />
    <meta name="keywords" content="" />
    <meta name="author" content="<%= ctx.sharing.author %>" />
    <meta name="copyright" content="" />
    <meta name="application-name" content="" />
    <!-- meta For Facebook -->
    <meta property="og:title" content="<%= ctx.sharing.title %>" />
    <meta property="og:type" content="article" />
    <meta property="og:image" content="<%= ctx.sharing.image %>" />
    <meta property="og:url" content="" />
    <meta property="og:description" content="<%= ctx.sharing.description %>" />
    <!-- meta For Twitter -->
    <meta name="twitter:card" content="summary" />
    <meta name="twitter:title" content="<%= ctx.sharing.title %>" />
    <meta name="twitter:description" content="<%= ctx.sharing.description %>" />
    <meta name="twitter:image" content="<%= ctx.sharing.image %>" />
    <!-- Common CSS -->
    [...]
  </head>

  <body class="container"><!-- or .container-fluid -->
    [...]
  </body>
</html>
```

You can test your markup for Facebook on <https://developers.facebook.com/tools/debug/sharing/>:

![](/assets/images/2018/08/Test-your-Facebook-markup.jpg)

Source:
- <https://stackoverflow.com/questions/11616697/how-to-use-the-og-open-graph-meta-tag-for-facebook-share#answer-16822848> 
- <https://developers.facebook.com/docs/sharing/webmasters#images>
