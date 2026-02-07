---
title: Generate URLs and links in Prestashop 1.7
permalink: /2018/04/generate-urls-in-prestashop-1-7/
categories: [prestashop,prestashop 1.7]
---
You always need to generate your links and URLs. Hardcoded ones are a really bad habit. Coming from a Symfony environment, I'm familiar with `$router->generate('my-route')`  but how does it work in PrestaShop? It turns out there are 2 ways depending on either you're generating a frontend or a backend link.

<!--more-->

## Generate a Frontend URL

## Generate a Backend URL

```php
// Generic
$this->context->link->getAdminLink('AdminControllerHere')
$this->context->link->getAdminLink($this->controller_name) // from an AdminController

// Objects
// link to view a Customer
$this->context->link->getAdminLink('AdminCustomers')."&viewcustomer&id_customer=$id_customer";
// link to update a Category
$this->context->link->getAdminLink('AdminCategories')."&updatecategory&id_category=$id_category";
// link to update an Employee
$this->context->link->getAdminLink('AdminEmployees')."&updateemployee&id_employee=$id_employee";

// Modules
// go to a module config page
$this->context->link->getAdminLink('AdminModules')."&configure=module_name&module_name=module_name"
// go to a module config page, from the module itself
$this->context->link->getAdminLink('AdminModules')."&configure={$this->name}&module_name={$this->name}"
```

## How to redirect

See [this article on how to redirect in Prestashop]({% post_url 2018/2018-04-19-redirects-in-prestashop-1-7 %})
