---
id: 434
title: 'Constants and variables for Prestashop 1.7 [PHP, Smarty, Javascript, Twig]'
date: 2018-04-25T21:27:05+00:00
layout: post
permalink: /2018/04/constants-and-variables-for-prestashop/
categories:
  - prestashop
  - prestashop 1.7
---
Ever wondered what constant to use in your controllers? Is it `_PS_ROOT_DIR_` or `__PS_BASE_URI__`? In smarty templates, would you go for `{$urls.img_dir}` or `{$img_dir}`? Which constant to use? What variable are available? This article walks you through the different PHP, Smarty Javascript and Twig constants & variables at your disposal and present them with examples and contexts.

<!--more-->

This guide assumes you have:

* a shop at <span class="lang:default decode:true crayon-inline">https://myshop.com/prefix/</span>
* hosted on your server on <span class="lang:default decode:true crayon-inline">/var/www/html/prestashop/</span>.
* Theme: <span class="lang:default decode:true crayon-inline ">my_theme</span>
* Admin dir: <span class="lang:default decode:true crayon-inline ">admin-dev</span>

* Langages: PHP, Smarty, Javascript
* Type:
    * Full path: Full path on your server (e.g. /var/www/html/prestashop/README.md)
    * Relative path: Relative path from prestashop install directory (e.g. /classes)
    * Full URL: Full URL including protocol (http/https) (e.g. http://myshop.com/prefix/)
    * Relative URL: Relative URL from prestashop install directory (e.g. /img/c)
* Available in frontoffice
* Available in backoffice

Use the filter below to select your categories:

{% raw %}
|Name|Language|Example|Type|Front, back?|
|-|-|-|-|-|
|\_PS_ROOT_DIR_|PHP|/var/www/html/prestashop|full path|front + back|
|\_PS_CORE_DIR_|PHP|/var/www/html/prestashop|full path|front + back|
|\_PS_ADMIN_DIR_|PHP|/var/www/html/prestashop/admin-dev|full path|back|
|basename(_PS_ADMIN_DIR_)|PHP|admin-dev|folder name|back|
|\__PS_BASE_URI__|PHP|/prefix/|relative url| |
|\_PS_MODE_DEV_|PHP|true|bool|front + back|
|\_PS_DEBUG_SQL_|PHP|true|bool|front + back|
|\_PS_THEME_URI_|PHP| | | |
|\_PS_DEBUG_PROFILING_|PHP|true|bool|front + back|
|\_PS_MODE_DEMO_|PHP|true|bool|front + back|
|\_PS_ALL_THEMES_DIR_|PHP|/var/www/html/prestashop/themes/| |front + back|
|\_PS_BO_ALL_THEMES_DIR_|PHP|/var/www/html/prestashop/Backoffice/themes/| |front + back|
|\_PS_CACHE_DIR_|PHP|/var/www/html/prestashop/app/cache/dev/| |front + back|
|\_PS_CONFIG_DIR_|PHP|/var/www/html/prestashop/config/| |front + back|
|\_PS_CUSTOM_CONFIG_FILE_|PHP|/var/www/html/prestashop/config/settings_custom.inc.php| |front + back|
|\_PS_CLASS_DIR_|PHP|/var/www/html/prestashop/classes/| |front + back|
|\_PS_DOWNLOAD_DIR_|PHP|/var/www/html/prestashop/download/| |front + back|
|\_PS_MAIL_DIR_|PHP|/var/www/html/prestashop/mails/| |front + back|
|\_PS_MODULE_DIR_|PHP|/var/www/html/prestashop/modules/| |front + back|
|\_PS_OVERRIDE_DIR_|PHP|/var/www/html/prestashop/override/| |front + back|
|\_PS_PDF_DIR_|PHP|/var/www/html/prestashop/pdf/| |front + back|
|\_PS_TRANSLATIONS_DIR_|PHP|/var/www/html/prestashop/translations/| |front + back|
|\_PS_UPLOAD_DIR_|PHP|/var/www/html/prestashop/upload/| |front + back|
|\_PS_CONTROLLER_DIR_|PHP|/var/www/html/prestashop/controllers/| |front + back|
|\_PS_ADMIN_CONTROLLER_DIR_|PHP|/var/www/html/prestashop/controllers/admin/| |front + back|
|\_PS_FRONT_CONTROLLER_DIR_|PHP|/var/www/html/prestashop/controllers/front/| |front + back|
|\_PS_TOOL_DIR_|PHP|/var/www/html/prestashop/tools/| |front + back|
|\_PS_GEOIP_DIR_|PHP|/var/www/html/prestashop/app/Resources/geoip/| |front + back|
|\_PS_GEOIP_CITY_FILE_|PHP|GeoLite2-City.mmdb| |front + back|
|\_PS_VENDOR_DIR_|PHP|/var/www/html/prestashop/vendor/| |front + back|
|\_PS_PEAR_XML_PARSER_PATH_|PHP|/var/www/html/prestashop/tools/pear_xml_parser/| |front + back|
|\_PS_SWIFT_DIR_|PHP|/var/www/html/prestashop/tools/swift/| |front + back|
|\_PS_TAASC_PATH_|PHP|/var/www/html/prestashop/tools/taasc/| |front + back|
|\_PS_TCPDF_PATH_|PHP|/var/www/html/prestashop/tools/tcpdf/| |front + back|
|\_PS_IMG_DIR_|PHP|/var/www/html/prestashop/img/| |front + back|
|\_PS_CORE_IMG_DIR_|PHP|/var/www/html/prestashop/img/| |front + back|
|\_PS_CAT_IMG_DIR_|PHP|/var/www/html/prestashop/img/c/| |front + back|
|\_PS_COL_IMG_DIR_|PHP|/var/www/html/prestashop/img/co/| |front + back|
|\_PS_EMPLOYEE_IMG_DIR_|PHP|/var/www/html/prestashop/img/e/| |front + back|
|\_PS_GENDERS_DIR_|PHP|/var/www/html/prestashop/img/genders/| |front + back|
|\_PS_LANG_IMG_DIR_|PHP|/var/www/html/prestashop/img/l/| |front + back|
|\_PS_MANU_IMG_DIR_|PHP|/var/www/html/prestashop/img/m/| |front + back|
|\_PS_ORDER_STATE_IMG_DIR_|PHP|/var/www/html/prestashop/img/os/| |front + back|
|\_PS_PROD_IMG_DIR_|PHP|/var/www/html/prestashop/img/p/| |front + back|
|\_PS_SHIP_IMG_DIR_|PHP|/var/www/html/prestashop/img/s/| |front + back|
|\_PS_STORE_IMG_DIR_|PHP|/var/www/html/prestashop/img/st/| |front + back|
|\_PS_SUPP_IMG_DIR_|PHP|/var/www/html/prestashop/img/su/| |front + back|
|\_PS_TMP_IMG_DIR_|PHP|/var/www/html/prestashop/img/tmp/| |front + back|
|\_PS_CACHEFS_DIRECTORY_|PHP|/var/www/html/prestashop/cache/cachefs/| |front + back|
|\_PS_JQUERY_VERSION_|PHP|1.11.0| |front + back|
|\_PS_CACHE_CA_CERT_FILE_|PHP|/var/www/html/prestashop/app/cache/dev/cacert.pem| |front + back|
|\_PS_DEFAULT_THEME_NAME_|PHP|classic| |front + back|
|\_PS_THEME_DIR_|PHP|/var/www/html/prestashop/themes/my_theme/|full path|front + back|
|\_PS_THEME_URI_|PHP|/prefix/themes/my_theme/|relative url|front + back|
|\_PS_PARENT_THEME_DIR_|PHP|/var/www/html/prestashop/themes/classic/|full path|front + back|
|\_PS_PARENT_THEME_URI_|PHP|/prefix/themes/classic/|relative url|front + back|
|\_THEMES_DIR_|PHP|/prefix/themes/|relative url|front + back|
|\_THEME_DIR_|PHP|/prefix/themes/my_theme/|relative url|front + back|
|\_THEME_IMG_DIR_|PHP|/prefix/themes/my_theme/assets/img/|relative url|front + back|
|\_THEME_CSS_DIR_|PHP|/prefix/themes/my_theme/assets/css/|relative url|front + back|
|\_THEME_JS_DIR_|PHP|/prefix/themes/my_theme/assets/js/|relative url|front + back|
|\_PS_IMG_|PHP|/prefix/img/|relative url|front + back|
|\_PS_ADMIN_IMG_|PHP|/prefix/img/admin/|relative url|front + back|
|\_PS_TMP_IMG_|PHP|/prefix/img/tmp/|relative url|front + back|
|\_THEME_CAT_DIR_|PHP|/prefix/img/c/|relative url|front + back|
|\_THEME_PROD_DIR_|PHP|/prefix/img/p/|relative url|front + back|
|\_THEME_MANU_DIR_|PHP|/prefix/img/m/|relative url|front + back|
|\_THEME_SUP_DIR_|PHP|/prefix/img/su/|relative url|front + back|
|\_THEME_SHIP_DIR_|PHP|/prefix/img/s/|relative url|front + back|
|\_THEME_STORE_DIR_|PHP|/prefix/img/st/|relative url|front + back|
|\_THEME_LANG_DIR_|PHP|/prefix/img/l/|relative url|front + back|
|\_THEME_COL_DIR_|PHP|/prefix/img/co/|relative url|front + back|
|\_THEME_GENDERS_DIR_|PHP|/prefix/img/genders/|relative url|front + back|
|\_PS_PROD_IMG_|PHP|/prefix/img/p/|relative url|front + back|
|\_PS_JS_DIR_|PHP|/prefix/js/|relative url|front + back|
|\_PS_CSS_DIR_|PHP|/prefix/css/|relative url|front + back|
|\_THEME_PROD_PIC_DIR_|PHP|/prefix/upload/|relative url|front + back|
|\_MAIL_DIR_|PHP|/prefix/mails/|relative url|front + back|
|\_MODULE_DIR_|PHP|/prefix/modules/|relative url|front + back|
|`\Context::getContext()`|PHP|Object of class <a href="https://github.com/PrestaShop/PrestaShop/blob/1.7.2.x/classes/Context.php">Context</a>|Object|front + back|
|\_DB_PREFIX_|PHP|Your SQL table prefix| | |
|{$baseAdminUrl}|Smarty|/prefix/admin-dev/|relative url|back|
|{$base_url}|Smarty|https://myshop.com/prefix/|full url|back|
|{$context_mode}|Smarty| | | |
|{$logged_on_addons}|Smarty| | | |
|{$can_import}|Smarty| | | |
|{$table}|Smarty|customers| |back|
|{$current}|Smarty|index.php?controller=AdminCustomer| |back|
|{$token}|Smarty|Token used in the current URL| |back|
|{$host_mode}|Smarty| | | |
|{$stock_management}|Smarty| | | |
|{$no_order_tip}|Smarty| | | |
|{$no_customer_tip}|Smarty| | | |
|{$no_customer_message_tip}|Smarty| | | |
|{$GA_ACCOUNT_ID}|Smarty| | | |
|{$displayBackOfficeHeader}|Smarty| | | |
|{$displayBackOfficeTop}|Smarty| | | |
|{$submit_form_ajax}|Smarty| | | |
|{$breadcrumbs2}|Smarty| | | |
|{$quick_access_current_link_name}|Smarty| | | |
|{$quick_access_current_link_icon}|Smarty| | | |
|{$navigationPipe}|Smarty| | | |
|{$img_base_path}|Smarty|/admin-dev/| |back|
|{$check_url_fopen}|Smarty| | | |
|{$check_openssl}|Smarty| | | |
|{$add_permission}|Smarty| | | |
|{$addons_register_link}|Smarty| | | |
|{$addons_forgot_password_link}|Smarty| | | |
|{$help_link}|Smarty| | | |
|{$maintenance_mode}|Smarty| | | |
|{$debug_mode}|Smarty| | | |
|{$lite_display}|Smarty| | | |
|{$url_post}|Smarty|index.php?controller=AdminCustomer&token={token}| |back|
|{$show_page_header_toolbar}|Smarty| | | |
|{$page_header_toolbar_title}|Smarty| | | |
|{$title}|Smarty| | | |
|{$toolbar_btn}|Smarty| | | |
|{$page_header_toolbar_btn}|Smarty| | | |
|{$show_new_orders}|Smarty| | | |
|{$show_new_customers}|Smarty| | | |
|{$show_new_messages}|Smarty| | | |
|{$help_box}|Smarty| | | |
|{$round_mode}|Smarty| | | |
|{$brightness}|Smarty| | | |
|{$bo_width}|Smarty| | | |
|{$bo_color}|Smarty| | | |
|{$employee}|Smarty|Object of class <a href="https://github.com/PrestaShop/PrestaShop/blob/1.7.2.x/classes/Employee.php">Employee</a>|Object|back|
|{$search_type}|Smarty| | | |
|{$bo_query}|Smarty| | | |
|{$quick_access}|Smarty| | | |
|{$multi_shop}|Smarty| | | |
|{$shop_list}|Smarty| | | |
|{$current_shop_name}|Smarty|'My Shop'| | |
|{$shop}|Smarty|Object of class <a href="https://github.com/PrestaShop/PrestaShop/blob/1.7.2.x/classes/shop/ShopGroup.php">Shop</a>|Object|back|
|{$shop_group}|Smarty|Object of class <a href="https://github.com/PrestaShop/PrestaShop/blob/1.7.2.x/classes/shop/ShopGroup.php">ShopGroup</a>|Object|back|
|{$is_multishop}|Smarty| | | |
|{$multishop_context}|Smarty| | | |
|{$default_tab_link}|Smarty| | | |
|{$login_link}|Smarty| | | |
|{$collapse_menu}|Smarty| | | |
|{$img_dir}|Smarty|/prefix/img/| |back|
|{$iso}|Smarty|fr| |back|
|{$class_name}|Smarty|AdminCustomerController| |back|
|{$iso_user}|Smarty|fr| |back|
|{$country_iso_code}|Smarty|FR| |back|
|{$version}|Smarty|1.7.2.4| |back|
|{$lang_iso}|Smarty|fr| |back|
|{$full_language_code}|Smarty|fr| |back|
|{$full_cldr_language_code}|Smarty|fr-FR| |back|
|{$link}|Smarty|Object of class <a href="https://github.com/PrestaShop/PrestaShop/blob/1.7.2.x/classes/Link.php">Link</a>|Object|back|
|{$shop_name}|Smarty| | | |
|{$base_url}|Smarty| | | |
|{$current_parent_id}|Smarty| | | |
|{$tabs}|Smarty| | | |
|{$current_tab_level}|Smarty| | | |
|{$install_dir_exists}|Smarty| | | |
|{$pic_dir}|Smarty| | | |
|{$controller_name}|Smarty|AdminCustomer| |back|
|{$current}|Smarty|index.php?controller=AdminCustomer| | |
|{$currentIndex}|Smarty|index.php?controller=AdminCustomer| | |
|{$bootstrap}|Smarty| | | |
|{$default_language}|Smarty| | | |
|{$display_addons_connection}|Smarty| | | |
|{$urls}|Smarty| | | |
|{$urls.base_url}|Smarty|https://myshop.com/prefix/|full url|front|
|{$urls.current_url}|Smarty|https://myshop.com/prefix/v2-manager?show-old=1|full url|front|
|{$urls.shop_domain_url}|Smarty|https://myshop.com/prefix|full url|front|
|{$urls.img_ps_url}|Smarty|https://myshop.com/prefix/img/|full url|front|
|{$urls.img_cat_url}|Smarty|https://myshop.com/prefix/img/c/|full url|front|
|{$urls.img_lang_url}|Smarty|https://myshop.com/prefix/img/l/|full url|front|
|{$urls.img_prod_url}|Smarty|https://myshop.com/prefix/img/p/|full url|front|
|{$urls.img_manu_url}|Smarty|https://myshop.com/prefix/img/m/|full url|front|
|{$urls.img_sup_url}|Smarty|https://myshop.com/prefix/img/su/|full url|front|
|{$urls.img_ship_url}|Smarty|https://myshop.com/prefix/img/s/|full url|front|
|{$urls.img_store_url}|Smarty|https://myshop.com/prefix/img/st/|full url|front|
|{$urls.img_col_url}|Smarty|https://myshop.com/prefix/img/co/|full url|front|
|{$urls.img_url}|Smarty|https://myshop.com/prefix/themes/my_theme/assets/img/|full url|front|
|{$urls.css_url}|Smarty|https://myshop.com/prefix/themes/my_theme/assets/css/|full url|front|
|{$urls.js_url}|Smarty|https://myshop.com/prefix/themes/my_theme/assets/js/|full url|front|
|{$urls.pic_url}|Smarty|https://myshop.com/prefix/upload/|full url|front|
|{$urls.pages.address}|Smarty|https://myshop.com/prefix/adresse|full url|front|
|{$urls.pages.addresses}|Smarty|https://myshop.com/prefix/adresses|full url|front|
|{$urls.pages.authentication}|Smarty|https://myshop.com/prefix/connexion|full url|front|
|{$urls.pages.cart}|Smarty|https://myshop.com/prefix/panier|full url|front|
|{$urls.pages.category}|Smarty|https://myshop.com/prefix/index.php?controller=category|full url|front|
|{$urls.pages.cms}|Smarty|https://myshop.com/prefix/index.php?controller=cms|full url|front|
|{$urls.pages.contact}|Smarty|https://myshop.com/prefix/nous-contacter|full url|front|
|{$urls.pages.discount}|Smarty|https://myshop.com/prefix/reduction|full url|front|
|{$urls.pages.guest_tracking}|Smarty|https://myshop.com/prefix/suivi-commande-invite|full url|front|
|{$urls.pages.history}|Smarty|https://myshop.com/prefix/historique-commandes|full url|front|
|{$urls.pages.identity}|Smarty|https://myshop.com/prefix/identite|full url|front|
|{$urls.pages.index}|Smarty|https://myshop.com/prefix/|full url|front|
|{$urls.pages.my_account}|Smarty|https://myshop.com/prefix/mon-compte|full url|front|
|{$urls.pages.order_confirmation}|Smarty|https://myshop.com/prefix/confirmation-commande|full url|front|
|{$urls.pages.order_detail}|Smarty|https://myshop.com/prefix/index.php?controller=order-detail|full url|front|
|{$urls.pages.order_follow}|Smarty|https://myshop.com/prefix/suivi-commande|full url|front|
|{$urls.pages.order}|Smarty|https://myshop.com/prefix/commande|full url|front|
|{$urls.pages.order_return}|Smarty|https://myshop.com/prefix/index.php?controller=order-return|full url|front|
|{$urls.pages.order_slip}|Smarty|https://myshop.com/prefix/avoirs|full url|front|
|{$urls.pages.pagenotfound}|Smarty|https://myshop.com/prefix/page-introuvable|full url|front|
|{$urls.pages.password}|Smarty|https://myshop.com/prefix/recuperation-mot-de-passe|full url|front|
|{$urls.pages.pdf_invoice}|Smarty|https://myshop.com/prefix/index.php?controller=pdf-invoice|full url|front|
|{$urls.pages.pdf_order_return}|Smarty|https://myshop.com/prefix/index.php?controller=pdf-order-return|full url|front|
|{$urls.pages.pdf_order_slip}|Smarty|https://myshop.com/prefix/index.php?controller=pdf-order-slip|full url|front|
|{$urls.pages.prices_drop}|Smarty|https://myshop.com/prefix/promotions|full url|front|
|{$urls.pages.product}|Smarty|https://myshop.com/prefix/index.php?controller=product|full url|front|
|{$urls.pages.search}|Smarty|https://myshop.com/prefix/recherche|full url|front|
|{$urls.pages.sitemap}|Smarty|https://myshop.com/prefix/Sitemap|full url|front|
|{$urls.pages.stores}|Smarty|https://myshop.com/prefix/magasins|full url|front|
|{$urls.pages.supplier}|Smarty|https://myshop.com/prefix/fournisseur|full url|front|
|{$urls.pages.register}|Smarty|https://myshop.com/prefix/connexion?create_account=1|full url|front|
|{$urls.pages.order_login}|Smarty|https://myshop.com/prefix/commande?login=1|full url|front|
|prestashop.cart|Javascript|products: [], totals:[], subtotal:[], products_count, summary_string| |front|
|prestashop.configuration|Javascript| | |front|
|prestashop.currency|Javascript|name:'euro', iso_code:'EUR', iso_code_num:'978&#8243;, sign:'€'| |front|
|currency|Javascript|name:'euro', iso_code:'EUR', format:'', sign:'€'| |front|
|prestashop.customer|Javascript|`lastname`:`'AAA'`, `firstname`:`'bbb'`, `email`:'aaa@bbb.com', ...| |front|
|prestashop.language|Javascript|`name`: 'Français (French)', `iso_code`: `'fr'`, `locale`: 'fr-FR', `language_code`: `'fr'`, `is_rtl`: `'0'`,...| |front|
|prestashop.page|Javascript|`title`:`''`, `canonical`: `null`, `meta`: `{}`, `page_name`: `'index'`, `body_classes`, ...| |front|
|prestashop.shop|Javascript|name: `''`, email: `''`, registration_number: `false`, long: `false`, lat: `false`| |front|
|prestashop.urls|Javascript|`base_url`:`''`, `current_url`:`''`, `shop_domain_url`:`''`, `img_ps_url`:`''`, `img_cat_url`:'', ...| |front|
|baseAdminDir|Javascript|/prefix/admin-dev/| |back|
|baseDir|Javascript|/prefix/| |back|
|token|Javascript|token used in current URL &token={token}| |back|
|token_admin_orders|Javascript|???| |back|
|token_admin_customers|Javascript|???| |back|
|token_admin_customer_threads|Javascript|???| |back|
|\_PS_VERSION_|Javascript|'1.7.2.4'| |back|
|help_class_name|Javascript|'AdminDashboard'| |back|
|default_currency|Twig|$| | |
|root_url|Twig|/prefix/| | |
|app|Twig|object of class <a href="http://api.symfony.com/master/Symfony/Bridge/Twig/AppVariable.html">AppVariable</a>| | |
{% endraw %}

*Source: mainly based on [https://github.com/PrestaShop/PrestaShop/blob/1.7.2.x/config/defines.inc.php](https://github.com/PrestaShop/PrestaShop/blob/1.7.2.x/config/defines.inc.php)*

\* \* \*

<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
<script type="text/javascript">
  $(function(){
    $('main > article > .post-content > table').DataTable({
      pageLength: 50,
    });
  });
</script>
