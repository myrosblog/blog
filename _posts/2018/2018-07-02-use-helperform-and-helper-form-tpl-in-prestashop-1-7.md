---
id: 705
title: Use Helper Form and helper/form.tpl in Prestashop 1.7
date: 2018-07-02T16:50:40+00:00
layout: post
permalink: /2018/07/use-helperform-and-helper-form-tpl-in-prestashop-1-7/
categories:
  - opensource
  - prestashop
  - prestashop 1.7
---
PrestaShop has developed a great UI for its Backoffice, and one of the not-so-well-known powerful features is the <span class="lang:php decode:true crayon-inline ">HelperForm</span>  object. You can create pretty much anything you want with it, but the official documentation is not complete and lacks some examples. Here's a live preview of all the features provided by this wonderful Helper object.

<!--more-->

Source: Most of the code here has been taken from the [AdminPatternsController](https://github.com/PrestaShop/PrestaShop/blob/1.7.3.x/controllers/admin/AdminPatternsController.php). You can preview it fully from your backoffice <http://bo.demo.prestashop.com/demo/index.php?controller=AdminPatterns&email=demo@prestashop.com&password=prestashop_demo>.

<script type="text/javascript">
  document.querySelector('head').innerHTML = '<link rel="stylesheet" href="{{'/assets/prestashop-1.7.3-assets/css/admin-theme.css'|relative_url}}" type="text/css" />' + document.querySelector('head').innerHTML;
</script>

<div id="content" class="bootstrap p-0">
  <div class="form-horizontal">
    <div class="panel">
      <div class="panel-heading">
        <i class="icon-edit"></i> Patterns of helper form.tpl and HelperForm
      </div><!-- /.panel-heading -->


      <div class="alert alert-success">...</div>

      <div class="alert alert-info">...</div>

      <hr>

      <div class="form-group">
        <label class="control-label col-lg-3 required">required input text</label>

        <div class="col-lg-9">
          <input id="type_text_required" class="" name="type_text_required" required="required" type="text" value="" placeholder="placeholder here" />
        </div>
      </div>
{% highlight php %}
[
  'type' => 'text',
  'label' => 'required input text',
  'name' => 'type_text_required',
  'required' => true,
  'placeholder' => 'placeholder here'
]
{% endhighlight %}

      <hr>

      <div class="form-group">
        <label class="control-label col-lg-3"><br /> input md with prefix+suffix<br /> </label>

        <div class="col-lg-9">
          <div class="input-group input fixed-width-md">
            <span class="input-group-addon">prefix</span><input id="type_text_md" class="input fixed-width-md" name="type_text_md" type="text" value="" /><span class="input-group-addon">suffix</span>
          </div>

          <p class="help-block">
            desc input text
          </p>
        </div>
      </div>
{% highlight php %}
[
  'type' => 'text',
  'label' => 'input fixed-width-md with prefix+suffix',
  'name' => 'type_text_md',
  'class' => 'input fixed-width-md',
  'prefix' => 'prefix',
  'suffix' => 'suffix',
  'desc' => 'desc input text'
]
{% endhighlight %}

      <hr>

      <div class="form-group">
        <label class="control-label col-lg-3">input with button</label>

        <div class="col-lg-9">
          <div class="row">
            <div class="col-lg-9">
              <input id="type_textbutton" class="" name="type_textbutton" type="text" value="" />
            </div>

            <div class="col-lg-2">
              <button class="btn btn-default" type="button" onclick="alert('something done');">do something</button>
            </div>
          </div>
        </div>
      </div>
{% highlight php %}
[
  'type' => 'textbutton',
  'label' => 'input with button',
  'name' => 'type_textbutton',
  'button' => [
      'label' => 'do something',
      'attributes' => [
          'onclick' => 'alert('something done');'
      ]
  ]
]
{% endhighlight %}

    </div><!-- /.panel -->
  </div><!-- /.form-horizontal -->
</div><!-- /.bootstrap -->
