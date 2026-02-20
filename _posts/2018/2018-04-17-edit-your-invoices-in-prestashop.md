---
title: 'Edit your invoices in Prestashop 1.7 - How to create an Admin Controller?'
categories:
  - opensource
  - prestashop
  - prestashop 1.7
redirect_from: /2018/04/edit-your-invoices-in-prestashop/
---

Have you ever wanted to modify an order or an invoice directly in Prestashop? Tired of bypassing PS limitations via phpMyAdmin? You can create an Admin Controller in PS 1.7 to edit your invoices directly in your browser!

<!-- more -->

> You can also view this [tuto to completely customize an Admin Controller from scratch, with your Custom SQL Table]({% post_url 2018/2018-05-28-create-an-admin-for-a-customized-sql-table %})

<!--more-->

## Objective

With this tutorial, you will be able to create an Admin Controller to create and edit any [Prestashop class](https://github.com/PrestaShop/PrestaShop/tree/develop/classes). We will take [Order Invoice](https://github.com/PrestaShop/PrestaShop/blob/develop/classes/order/OrderInvoice.php) as an example. This way, we can add, remove and edit any field of any invoice in Prestashop.

This extension will be available in your Backoffice through a URL that looks like this:

https://my.presta.com/admin/index.php?controller=AdminCustomInvoices

We have to:
1. Create the module and a simple  Admin Controller
1. Edit the Admin Controller to present all invoices in a list
1. Edit it again to add/edit invoices

## Create the Admin Controller (via a Module)

Admin Controllers only exist in a module. So we need to create a module first! Let's create a dummy module in `modules/fc_invoice/fc_invoice.php` :

```php
<?php
if (!defined('_PS_VERSION_')) {exit;}
class Fc_Invoice extends Module {
  public function __construct() {
    $this->name = 'fc_invoice';
    $this->tab = 'administration';
    $this->version = '1.0.0';
    $this->author = 'Myros';
    $this->bootstrap = true;
    parent::__construct();
    $this->displayName = $this->l('FC Invoice Module');
    $this->description = $this->l('Improve your store with FC modules');
    $this->ps_versions_compliancy = ['min' => '1.7', 'max' => _PS_VERSION_];
  }
  
  public function install(){
    return parent::install() && $this->_installTab();
  }
  
  protected function _installTab(){
    $tab = new Tab();
    $tab->class_name = 'AdminFcInvoice';
    $tab->module = $this->name;
    $tab->id_parent = (int)Tab::getIdFromClassName('DEFAULT');
    $tab->icon = 'settings_applications';
    $languages = Language::getLanguages();
    foreach ($languages as $lang) {
        $tab->name[$lang['id_lang']] = $this->l('FC Invoice');
    }
    $tab->save();
  }
}
```

Then, activate it through the PrestShop Backoffice by looking for `fc`:

![](/assets/images/2018/05/search-for-my_module-in-the-backoffice-annote.jpg)


Finally, we can create our actual `AdminCustomInvoicesController` in `modules/fc_module/controllers/admin/AdminFcInvoiceController.php`:

```php
class AdminFcInvoiceController extends ModuleAdminController {
  public function __construct(){
    $this->bootstrap = true; // use Bootstrap CSS
    $this->table = 'order_invoice'; // SQL table name, will be prefixed with _DB_PREFIX_
    $this->className = 'OrderInvoice'; // PHP class name
    $this->allow_export = true; // allow export in CSV, XLS..
    $this->_orderBy = 'id_order_invoice';
  }
}
```


Let's check that everything is working well by heading to `https://my.presta.com/admin/index.php?controller=AdminFcInvoice` :
![](/assets/images/2018/04/screenshot-2018-07-06-20.03.54.png)


NB: if you get a page not found error like below:
![](/assets/images/2018/04/screenshot-2018-07-06-19.53.18.png)

Prestashop uses `Tab` to whitelist Controllers, you may need to execute directly in the database:
```sql
INSERT INTO `ps_tab` (id_parent, position, module, class_name, active)
VALUES (3, 6, 'fc_module', 'AdminFcInvoice', 1);
```

## Add the List feature

For example, an Admin Controller to handle your invoices (list, view, create, edit and delete)

```php
class AdminCustomInvoicesController extends ModuleAdminController {
  public function __construct(){
    // [...]

    $this->fields_list = [
      'id_order_invoice' => ['title' => $this->trans('ID', [], 'Admin.Global'),'class' => 'fixed-width-xs'],
      'number' => ['title' => $this->trans('Number', [], 'Admin.Global'),'class' => 'fixed-width-xs'],
      'date_add' => ['title' => $this->trans('Date', [], 'Admin.Global'), 'type'=>'datetime'],
      'total_products_wt' => ['title' => $this->trans('Total products', [], 'Admin.Global'),
        'align' => 'text-right',
        'type' => 'price',
      ],
      'total_shipping_tax_incl' => ['title' => $this->trans('Total shipping', [], 'Admin.Global'),
        'align' => 'text-right',
        'type' => 'price',
      ],
      'total_paid_tax_incl' => ['title' => $this->trans('Total paid', [], 'Admin.Global'),
        'align' => 'text-right',
        'type' => 'price',
      ],
    ];
  }
}
```

Which gives us the following list (sortable and filterable!!):

![](/assets/images/2018/04/screenshot-2018-07-06-20.22.49.png)

## Add the edit & add features

Add `$this->fields_form`  and `$this->addRowAction`:

```php
class AdminCustomInvoicesController extends ModuleAdminController {
  public function __construct(){
    // [...]

    $this->addRowAction('edit');
    $this->addRowAction('details');

    $this->fields_form = [
      'legend' => ['title' => $this->l('Custom Invoice'),'icon' => 'icon-list-ul'],
      'input' => [
        ['name' => 'date_add','type' => 'datetime','label' => 'Date add',],
        ['name'=>'number','type'=>'text','required' => true,'label' => 'Number',],
        ['name'=>'note','type'=>'textarea','label' => 'Note',],
        ['name'=>'delivery_number','type'=>'text','label'=>'Delivery number'],
        ['name'=>'delivery_date','type'=>'datetime','label'=>'Delivery date'],
        ['name'=>'total_discount_tax_excl','type'=>'text','label'=>'Total amount of discounts (no tax)'],
        ['name'=>'total_discount_tax_incl','type'=>'text','label'=>'Total amount of discounts (with tax)'],
        ['name'=>'total_shipping_tax_excl','type'=>'text','label'=>'Total cost of shipping (no tax)'],
        ['name'=>'total_shipping_tax_incl','type'=>'text','label'=>'Total cost of shipping (with tax)'],
        ['name'=>'total_products','type'=>'text','label'=>'Total cost of products (no tax)'],
        ['name'=>'total_products_wt','type'=>'text','label'=>'Total cost of products (with tax)'],
        ['name'=>'total_wrapping_tax_excl','type'=>'text','label'=>'Total cost of wrapping (no tax)'],
        ['name'=>'total_wrapping_tax_incl','type'=>'text','label'=>'Total cost of wrapping (with tax)'],
        ['name'=>'total_paid_tax_excl','type'=>'text','label'=>'Total paid (no tax)'],
        ['name'=>'total_paid_tax_incl','type'=>'text','label'=>'Total paid (with tax)'],
        ['name'=>'shop_address','type'=>'textarea','label'=>'Shop address'],
      ],
      'submit' => ['title' => $this->trans('Save', [], 'Admin.Actions'),],
    ];
  }
}
```

This new code adds buttons in the last column:

![](/assets/images/2018/04/screenshot-2018-07-06-20.35.30.png)


And hitting Edit results in a nice form, ready to be edited!

![](/assets/images/2018/04/screenshot-2018-07-06-20.32.55.png)

## Going further

### 4. a) Add customer info in the list

```php
class AdminCustomInvoicesController extends ModuleAdminController {
  public function __construct(){
    // [...]
    $this->_select = 'concat(upper(c.lastname), " ", c.firstname) as customer';
    $this->_join = '
      JOIN '._DB_PREFIX_.'orders o ON (o.id_order = a.id_order)
      JOIN '._DB_PREFIX_.'customer c ON (c.id_customer = o.id_customer)
    ';

    $this->fields_list = [
      // [...]
      'customer' => ['title' => $this->trans('Customer', [], 'Admin.Global')],
      // [...]
    ];
  }
}
```

Displays the customer name in a column:

![](/assets/images/2018/04/screenshot-2018-07-06-20.43.05.png)

### 4. b) Add order info above the form

```php
class AdminCustomInvoicesController extends ModuleAdminController {
  // [...]

  public function renderForm(){
    $invoice = $this->object; // get invoice
    $order = $invoice->getOrder(); // get order
    $customer = $order->getCustomer(); // get customer
    $currency = new Currency($order->id_currency); // get currency
    // add some info in an HTML string
    $info = '<div class="panel">';
    $info .= '<div class="panel-heading"><i class="icon-list-ul"></i> Order informations</div>';
    $info .= "Order reference: {$order->reference}<br/>";
    $info .= "Customer: {$customer->firstname} {$customer->lastname}<br/>";
    $info .= "Total_paid : ".Tools::displayPrice($order->total_paid, $currency)."<br/>";
    $info .= "Get total paid : ".Tools::displayPrice($order->getTotalPaid(), $currency)."<br/>";
    $info .= "Payment: {$order->payment}<br/>";
    $info .= "Order state : {$order->getCurrentOrderState()->name[$this->context->language->id]}";
    $info .= '</div>';
    // push the HTML to $this->content
    $this->content .= $info;
    return parent::renderForm();
  }
}
```

And we now have a simple panel that serves as a header to render some data about the order and the customer:

![](/assets/images/2018/04/screenshot-2018-07-06-20.47.58.png)

### 4. c) Delete an invoice

USE WITH CARE, you CANNOT undo a deletion!!!

```php
class AdminCustomInvoicesController extends ModuleAdminController {
  public function __construct(){
    // [...]

    $this->addRowAction('delete');
    $this->bulk_actions = [
      'delete' => [
        'text' => 'Delete',
        'icon' => 'icon-power-off'
      ],
    ];
  }
}
```

This new code will add buttons to delete via one-shot and bulk:

![](/assets/images/2018/04/screenshot-2018-07-06-20.52.22.png)


## Full version of the Code

Hosted on <a href="https://gist.github.com/myrosblog/cb63fd5abd93e1109fcf624a68307403">https://gist.github.com/myrosblog/cb63fd5abd93e1109fcf624a68307403</a>


Mobile and responsive version:

![](/assets/images/2018/04/screencapture-app-bonnemine-co-Backoffice-index-php-2018-06-12-10_17_27.png)
