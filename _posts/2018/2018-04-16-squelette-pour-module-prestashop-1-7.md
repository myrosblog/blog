---
title: Squelette pour module Prestashop 1.7
redirect_from: /2018/04/squelette-pour-module-prestashop-1-7/
categories:
  - prestashop
  - prestashop 1.7
---
  1. Basic
  2. Add a config page
  3. Make it multi shop
  4. Good practices for Dabatabse install/uninstall
  5. Work with a Composer library

## Most basic

```
- modules
  - fc_redirect
    - fc_redirect.php
```

```php
if (!defined('_PS_VERSION_')) {exit;}
class Fc_Redirect extends Module { 
      public function __construct() { 
      $this->name = 'fc_redirect';
      $this->tab = 'administration';
      $this->version = '1.0.0';
      $this->author = 'Myros';
      $this->bootstrap = true;
      parent::__construct();
      $this->displayName = $this->l('PrestaShop Redirect by FC');
      $this->description = $this->l('Improve your store by avoiding 404 errors and redirecting customers to existing pages!');
      $this->ps_versions_compliancy = array('min' => '1.7', 'max' => _PS_VERSION_);
  }

  public function install(){
      return (
          parent::install() &&
          $this->registerHook('actionDispatcher')
      );
  }

  public function hookActionDispatcher($params = []){
      if(!$this->context || !$this->context->controller){
        return;
      }
      // do things!
  }
}
```

All hooks <http://build.prestashop.com/news/new-updated-hooks-1-7-1-0/>

## Add a config page

Must have `getContent()` method

```php
// define your confuguration keys + default value here
  const CONFS = [
    'FCSENTRY_DSN' => '',
    'FCSENTRY_ALLOW_BO' => true,
  ];
  // define a value for your form submit button
  const SUBMIT = 'submitFcSlack';

 public function getContent(){
   if (((bool)Tools::isSubmit(self::SUBMIT)) == true) {
     $this->postProcess(); // see at the bottom
   }
   return $this->renderForm(); // see below
 }

  /**
   * Create the form that will be displayed in the configuration of your module.
   */
  protected function renderForm()
  {
      $helper = new HelperForm();

      $helper->show_toolbar = false;
      $helper->table = $this->table;
      $helper->module = $this;
      $helper->default_form_language = $this->context->language->id;
      $helper->allow_employee_form_lang = Configuration::get('PS_BO_ALLOW_EMPLOYEE_FORM_LANG', 0);

      $helper->identifier = $this->identifier;
      $helper->submit_action = self::SUBMIT;
      $helper->currentIndex = $this->context->link->getAdminLink('AdminModules', false)
          .'&configure='.$this->name.'&tab_module='.$this->tab.'&module_name='.$this->name;
      $helper->token = Tools::getAdminTokenLite('AdminModules');

      $helper->tpl_vars = array(
          'fields_value' => $this->getConfigFormValues(), // see below
          'languages' => $this->context->controller->getLanguages(),
          'id_language' => $this->context->language->id,
      );

      return $helper->generateForm(array($this->getConfigForm())); // see below
  }


  /**
   * Set values for the inputs.
   */
  protected function getConfigFormValues(){
      $return = [];
      foreach (self::CONFS as $key => $default) {
        $return[$key] = Configuration::get($key, $default);
      }
      return $return;
  }


protected function getConfigForm()
  {
      return array(
          'form' => array(
              'legend' => array(
              'title' => $this->l('Settings'),
              'icon' => 'icon-cogs',
              ),
              'input' => array(
                  // string input
                  array(
                      'col' => 8,
                      'type' => 'text',
                      'desc' => $this->l('Use the DSN provided by Sentry.io. Documentation here https://docs.sentry.io/quickstart/#about-the-dsn'),
                      'name' => 'FCSENTRY_DSN',
                      'label' => $this->l('DSN'),
                      'required' => true,
                  ),
                  // boolean input
                  array(
                      'type' => 'switch',
                      'label' => $this->l('Allow in Backoffice'),
                      'name' => 'FCSENTRY_ALLOW_BO',
                      'is_bool' => true,
                      'desc' => $this->l('Disable sentry if controller extends AdminController'),
                      'values' => array(
                          array(
                              'id' => 'active_on',
                              'value' => true,
                              'label' => $this->l('Enabled')
                          ),
                          array(
                              'id' => 'active_off',
                              'value' => false,
                              'label' => $this->l('Disabled')
                          )
                      ),
                  ),
               ), // end 'input'
               'submit' => array(
                 'title' => $this->l('Save'),
               ),
            ), // end 'form'
       );
    }


protected function postProcess(){
      $form_values = $this->getConfigFormValues();

      foreach (array_keys($form_values) as $key) {
          Configuration::updateValue($key, Tools::getValue($key));
      }
  }
```

Don't forget to update your install/uninstall methods:

```php
public function install()
  {
      foreach (self::CONFS as $key => $default) {
        Configuration::updateValue($key, $default);
      }
      return (
          parent::install() &&
          $this->registerHook('actionDispatcher')
      );
  }

public function uninstall(){
    $return = true;
    foreach (self::CONFS as $key => $default) {
      $return = $return && Configuration::deleteByName($key);
    }
    return (
      $return &&
      parent::uninstall()
    );
  }
```


## Make it multishop



## Good practices for Database install/uninstall

taken from <https://github.com/PrestaShop/gamification>

```php
/**
 * DATABASE INSTALL/UNINSTALL
 */
 public function installDb()
 {
   $return = true;
   include(dirname(__FILE__).'/sql_install.php');
   foreach ($sql as $s) {
     $return &= Db::getInstance()->execute($s);
   }
   return $return;
 }
 
 public function uninstallDb()
 {
   include(dirname(__FILE__).'/sql_install.php');
   foreach ($sql as $name => $v) {
     Db::getInstance()->execute('DROP TABLE '.$name);
   }
   return true;
 }
```

```php
$sql = [];
$sql[_DB_PREFIX_.'badge'] =
 'CREATE TABLE IF NOT EXISTS `'._DB_PREFIX_.'badge` (
 `id_badge` int(11) NOT NULL AUTO_INCREMENT,
 `type` varchar(32) NOT NULL,
 `awb` INT NULL DEFAULT \'0\',
 `validated` tinyint(1) unsigned NOT NULL DEFAULT 0,
 PRIMARY KEY (`id_badge`)
 ) ENGINE='._MYSQL_ENGINE_.' DEFAULT CHARSET=utf8;';
```

## Work with a Composer library

Go to your module directory `/modules/my_module`

```console
$ composer require maknz/slack
```

will create a `vendor` dir, with an `autoload.php` inside

So just do a `require_once __DIR__.'/vendor/autoload.php';`

```php
require_once __DIR__.'/vendor/autoload.php';

if (!defined('_PS_VERSION_')) {exit;}
class Fc_Slack extends Module {
  public function __construct() {
    
  }
}
```
