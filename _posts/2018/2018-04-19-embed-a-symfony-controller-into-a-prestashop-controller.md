---
title: Embed a Symfony controller into a Prestashop controller
permalink: /2018/04/embed-a-symfony-controller-into-a-prestashop-controller/
categories:
  - prestashop
  - prestashop 1.7
---
We are migrating from 100% Symfony to Prestashop 1.7 but we would like to keep and re-use our existing codebase. Here's a how-to.

## How Symfony works

URL > Router > Controller >  Symfony Services calls & DB calls via Doctrine > display Twig template

You go to a URL, which is mapped to a Controller via the `@Route` annotation. This Controller will fetch data from Services and directly from the database (through the Doctrine Service 😉), and then send those data to a template that will display them in a nice way.

## How Prestashop works

Pretty much the same way !

URL > Tab > Controller > Prestashop static functions & raw DB calls via PDO > display Smarty template

## Call symfony from a Prestashop Controller

In you are on a Backoffice page, the symfony `global $kernel`  is always available. If you're on a Frontoffice page, you have to create it manually (see [this page on how to work with the symfony kernel in Prestashop]({% post_url 2018/2018-05-02-how-to-work-with-the-symfony-kernel-anywhere-in-prestashop-1-7 %})):

```php
// for the front
require_once _PS_ROOT_DIR_.'/app/AppKernel.php';
$kernel = new \AppKernel('prod', false); // $env, $debug
$kernel->boot();
// or if for the back
// global $kernel;
$twig = $kernel->getContainer()->get('twig');
$html = $twig->render(_PS_ROOT_DIR_.'/src/YourBundle/Resources/views/Directory1/view1.html.twig', [
 'var1' => [],
 'var2' => 'your value here',
 'var3' => 123,
]);
```
