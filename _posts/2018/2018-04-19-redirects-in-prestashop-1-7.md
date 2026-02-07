---
title: Redirects in Prestashop 1.7
categories: [prestashop,prestashop 1.7]
---

## Redirects to Frontend

```php
Tools::redirect('index.php');
Tools::redirectLink('index.php');
$this->canonicalRedirection('??');
```

## Redirects to Backend

```php
Tools::redirectAdmin('urlHere');
Tools::redirectAdmin($this->context->link->getAdminLink('AdminControllerHere'));
Tools::redirectAdmin(Context::getContext()->link->getAdminLink(AdminDashboard::class));
```

## How to generate an URL

See [this article on how to generate an URL in Prestashop](/2018/04/generate-urls-in-prestashop-1-7/)
