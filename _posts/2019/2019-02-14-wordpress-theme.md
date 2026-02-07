---
title: Extend a WordPress Theme with a Child Theme
categories: [opensource,wordpress]
---
Instead of editing the PHP, HTML and CSS files of a WordPress theme, we'll extend it with the WordPress Child Themes system.

<p class="text-center">🔊♻️👩‍👦</p>

<!--more-->

## Intro
A child theme consists of re-using and editing parent style (CSS) and functions (PHP) without touching its code base. The child PHP will be loaded **before** the parent. Most of the parent PHP files declare their functions only if not previously declared:
```php
if (!function_exists ('hook1_in_parent')) {
  function hook1_in_parent() {
    // Content of the parent
  }
}
```

This allows to edit and replace any of the parent code.

## Bare minimum: `style.css` and `functions.php`

A theme needs to live in `/wp-content/my-theme-name/` and to contain at least `style.css` with this Style Header:
```css
/*
Mandatory
 Theme Name:   Myros WP Template
 Template:     twentyeighteen

Optional
 Theme URI:    http://myrosblog.com/2019/02/wordpress-theme
 Description:  Wordpress Child Theme Template by fc.com
 Author:       Myros
 Author URI:   http://myrosblog.com
 Version:      1.0.0
 License:      GNU General Public License v2 or later
 License URI:  http://www.gnu.org/licenses/gpl-2.0.html
 Tags:         light, dark, two-columns, right-sidebar, responsive-layout, accessibility-ready
*/
```

Our theme is now available in Administration > Themes. Activate it, but no CSS will be loaded.
We need to add the parent CSS style via PHP `wp_enqueue_scripts` in `functions.php`:
```php
<?php
add_action('wp_enqueue_scripts', 'my_styles'); // add_action($tag, $callable, $priority=10)
function my_styles() {
  wp_enqueue_style('parent', get_template_directory_uri().'/style.css'); // wp_enqueue_style($handle, $src, $deps=[], $version=null)
  wp_enqueue_style('child', get_stylesheet_directory_uri().'/style.css', ['parent'], wp_get_theme()->get('Version')); // get Version from CSS header
  wp_enqueue_style('bootstrap', 'https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/css/bootstrap.min.css'); // from CDN
}
```

`deps` ensures that we load the child CSS after the parent CSS. The above generates the following HTML:
```html
<link rel="stylesheet" id="parent-css" href="https://my-wp.fr/wp-content/themes/twentyeighteen/style.css?ver=4.9.4" type="text/css" media="all">
<link rel="stylesheet" id="bootstrap-css" href="https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/css/bootstrap.min.css" type="text/css" media="all">
<link rel="stylesheet" id="child-css" href="https://my-wp.fr/wp-content/themes/my-theme-name/style.css?ver=1.0.0" type="text/css" media="all">
```

*Note: `bootstrap-css` can be generated anywhere as it doesn't have any `deps` declared -> not recommended!!*

Reference:
- [https://developer.wordpress.org/themes/advanced-topics/child-themes/#3-enqueue-stylesheet](https://developer.wordpress.org/themes/advanced-topics/child-themes/#3-enqueue-stylesheet)
- [https://codex.wordpress.org/Plugin_API](https://codex.wordpress.org/Plugin_API)

## Add JS

Add another call to `wp_enqueue_scripts` at the end of `functions.php`:
```php
// end of functions.php
add_action('wp_enqueue_scripts', 'my_scripts'); // Can be called mutiple times with same tag
function my_scripts() {
    wp_enqueue_script('perso', get_stylesheet_directory_uri().'/script.js', [], 'v1.0.0'); // wp_enqueue_script($handle, $src, $deps=[], $version=null)
    wp_enqueue_script('jquery'); // from WordPress handle, see https://developer.wordpress.org/reference/functions/wp_enqueue_script/#default-scripts-included-and-registered-by-wordpress
    wp_enqueue_script('bs', 'https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/js/bootstrap.min.js'); // from CDN
}
```

*Note: scripts added with this method will be generated at the top of the page. If you want to add them before the closing `</body>` tag, see method "Hook anywhere" below*

## Hook anywhere

Call the action `wp_footer` to hook after the `</body>` tag (See https://codex.wordpress.org/Plugin_API/Action_Reference/wp_footer)
```php
// end of functions.php
add_action('wp_footer', 'my_footer');
function my_footer() {
    echo '<p>will be displayed <em>as is</em> before the closing body tag</p>';
    $scripts = [
      get_stylesheet_directory_uri().'/script.js?v=v1.0.0',
      'https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/js/bootstrap.min.js',
    ];
    foreach($s in $scripts){
      echo '<script src="'+$s+'"></script>';
    }
}
```

## Appendixes

2011 Schema of WP load order: core, plugins, child and parent theme
![](https://i.imgur.com/SqQQE.png)

See [Stackoverflow post](https://stackoverflow.com/questions/44647028/wordpress-functions-php-child-theme)

