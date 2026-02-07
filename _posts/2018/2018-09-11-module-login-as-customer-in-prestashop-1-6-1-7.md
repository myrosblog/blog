---
id: 993
title: Module Login as customer in Prestashop 1.6, 1.7
date: 2018-09-11T00:33:28+00:00
layout: post
permalink: /2018/09/module-login-as-customer-in-prestashop-1-6-1-7/
categories:
  - github
  - opensource
  - prestashop
  - prestashop 1.6
  - prestashop 1.7
---
With this module, as an admin you are now able to login as a customer in order to make orders, payments and edits to his profile. Source code included, open source.

<!--more-->

![todo](/assets/images/2018/09/FC-Login-as-Customer-module-prestashop.png)

The module consists in 2 files: the main module file `Fc_LoginAsCustomer`  and the front controller file `Fc_LoginAsCustomerLoginModuleFrontController`.

## Step 1. Create the main module

Create the main module file in `/modules/fc_loginascustomer/fc_loginascustomer.php`:

```php
<?php
if (!defined('_PS_VERSION_'))
  exit;

class Fc_LoginAsCustomer extends Module {

  public function __construct(){
    $this->name = 'fc_loginascustomer';
    $this->tab = 'back_office_features';
    $this->version = '1.0.0';
    $this->author = 'Myros';
    $this->controllers = ['login'];

    $this->bootstrap = true;
    parent::__construct();

    $this->displayName = $this->l('FC Login as customer');
    $this->description = $this->l('Allows you login as customer');

    $this->ps_versions_compliancy = array('min' => '1.6', 'max' => _PS_VERSION_);
  }

  public function install(){
    return (
      parent::install() &&
      $this->registerHook('displayAdminCustomers')
    );
  }

  public function hookDisplayAdminCustomers($params){
    $customer = New CustomerCore ((int)Tools::getValue("id_customer"));
    $link = $this->context->link->getModuleLink($this->name, 'login', [
      'id_customer' => $customer->id,
      'xtoken' => $this->makeToken($customer->id)
    ]);
   if(!Validate::isLoadedObject($customer)){
      return;
    }
    return '<div class="panel">
              <div class="panel-heading">
                <i class="icon-file"></i> '.$this->l("FC Login As Customer").' v'.$this->version.'
              </div>
              <p class="text-center">
                <a class="btn btn-default" href="'.$link.'" target="_blank">
                  <i class="icon-user"></i> '.$this->l("Login as customer").' '.$customer->email.'
                </a>
              </p>
          </div>';
  }

  public function makeToken($id_customer) {
    return md5(_COOKIE_KEY_.$id_customer.date("Ymd"));
  }
}
```

## Step 2. The Front Controller

and the Front controller in `/modules/fc_loginascustomer/controllers/front/login.php`:

```php
<?php

class Fc_LoginAsCustomerLoginModuleFrontController extends ModuleFrontControllerCore {
  public $ssl = true;

  public function postProcess() {
    parent::postProcess();
    $id_customer = (int)Tools::getValue('id_customer');
    if(!$id_customer || $id_customer < 0){
      die('bad $id_customer');
    }
    $xTokenOk = Tools::getValue('xtoken') == $this->module->makeToken($id_customer);
    if(!$xTokenOk){
      die('bad xtoken');
    }
    $customer = new Customer($id_customer);
    if (!Validate::isLoadedObject($customer)){
      die('bad customer object');
    }
    $customer->logged = 1;
    $this->context->customer = $customer;
    $this->context->cookie->id_customer = $customer->id;
    $this->context->cookie->customer_lastname = $customer->lastname;
    $this->context->cookie->customer_firstname = $customer->firstname;
    $this->context->cookie->logged = 1;
    $this->context->cookie->check_cgv = 1;
    $this->context->cookie->is_guest = $customer->isGuest();
    $this->context->cookie->passwd = $customer->passwd;
    $this->context->cookie->email = $customer->email;
    Tools::redirect('index.php?controller=my-account');
  }
}
```

_Source <https://www.prestashop.com/forums/topic/444031-free-module-login-as-customer/> refactored, cleaned and simplified._
