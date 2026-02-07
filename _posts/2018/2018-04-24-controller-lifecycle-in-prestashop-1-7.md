---
id: 409
title: Controller lifecycle in PrestaShop 1.7
date: 2018-04-24T18:20:19+00:00
layout: post
permalink: /2018/04/controller-lifecycle-in-prestashop-1-7/
categories:
  - prestashop
  - prestashop 1.7
---
Execution order of the controller's functions : <span class="lang:default decode:true crayon-inline">classes/controller/Controller.php</span> :

  1. __construct()
  2. run() (called by par Dispatcher->dispatch)
      1. checkAccess()
      2. init()
          1. AdminController->init():
              1. check employee
              2. $this->initProcess();
                  1. <span class="pl-smi">if $_POST filter, $this</span><span class="pl-k">-></span><span class="pl-smi">filter</span> <span class="pl-k">=</span> <span class="pl-c1">true</span>
                  2. Define $this->action based on different conditions
                  3. $this->action = delete\_image|delete|status|position|save|new|view|details|export|reset\_filters|toCamelCase <span class="pl-c1">Tools</span><span class="pl-k">::</span>getValue(<span class="pl-s"><span class="pl-pds">&#8216;</span>action<span class="pl-pds">&#8216;</span></span>)|update_fields|bulk|
                  4. can error <span style="color: #800000;">&#8216;You do not have permission to view/edit/add/delete this'</span>
              3. $this->initBreadcrumbs();
              4. $this->initModal();
              5. $this->initToolbarFlags();
                  1. $this->getLanguages
                  2. $this->initToolbar
                  3. $<span class="pl-smi">this</span><span class="pl-k">-></span>initTabModuleList
                  4. $<span class="pl-smi">this</span><span class="pl-k">-></span>initPageHeaderToolbar
                      1. <span style="color: #3366ff;">$this->loadObject</span> [in &#8216;view' or &#8216;edit'] can error <span style="color: #800000;"><span class="pl-pds">&#8216;</span>The object cannot be loaded (or found)</span><span class="pl-pds"><span style="color: #800000;">&#8216;</span> or <span style="color: #800000;">&#8216;The object cannot be loaded (the identifier is missing or invalid)'</span></span>
              6. $this->initNotifications();
          2. FrontController->init()
              1. // todo
      3. setMedia() or setMobileMedia(): Adds all JavaScript and CSS specifics to the page so that they can be combined, compressed and cached (see PrestaShop's CCC tool, in the back office "Performance" page, under the "Advanced preferences" menu).
      4.  AdminController->setMedia()
          1. $this->addCSS(themes, css, public, vendor)
          2. $this->addJS(themes, css, public, vendor, public bundle)
      5. postProcess()
          1. AdminController->postProcess()
              1. <span class="pl-smi">$this</span><span class="pl-k">-></span>processFilter() [if !$this->ajax && <span class="pl-smi">$this</span><span class="pl-k">-></span><span class="pl-smi">filter</span>]
              2. <span class="pl-s"><span style="color: #339966;">Hook</span> </span>actionAdmin{Action}Before
              3. <span class="pl-s"><span style="color: #339966;">Hook</span> action{Class}{Action}</span><span class="pl-s">Before</span>
              4. process{Action} (or ajaxProcess{Action} if $this->ajax)
              5. <span class="pl-s"><span style="color: #339966;">Hook</span> </span>actionAdmin{Action}After
              6. <span class="pl-s"><span style="color: #339966;">Hook</span> action{Class}{Action}</span><span class="pl-s">After</span>
          2. FrontController->postProcess()
      6. redirect() [if $this->redirect_after]
      7. initHeader()
      8. initContent()
          1. AdminController->initContent
              1. $this->viewAccess
              2. $this->loadObject(true)
              3. [if display == &#8216;edit' || &#8216;add']
                  1. loadObject(true)
                  2. renderForm
              4. [if display == &#8216;view']
                  1. loadObject(true)
                  2. renderView
              5. [if display == &#8216;details']
                  1. renderDetails
              6. elseif !$this->ajax
                  1. $this->renderModulesList()
                  2. $this->renderKpis()
                  3. $this->renderList()
                  4. $this->renderOptions()
                  5. $this->displayRequiredFields [if <span class="pl-smi">$this</span><span class="pl-k">-></span><span class="pl-smi">required_database</span>]
              7. assign &#8216;content'
          2. FrontController->initContent
              1. // todo
      9. initFooter()
     10. displayAjax() [if $this->ajax]
     11. display() [else]
          1. FrontController->smartyOutputContent
          2. AdminController->smartyOutputContent($this->layout)

test:

<table style="border-collapse: collapse; width: 100%;" border="1">
  <tr>
    <th style="width: 25%;">
      Function
    </th>

    <th style="width: 12.7586%;">
    </th>

    <th style="width: 17.2414%;">
    </th>

    <th style="width: 21.1207%;">
    </th>

    <th style="width: 10.3879%;">
    </th>

    <th style="width: 8.46985%;">
      Condition
    </th>

    <th style="width: 5.02155%;">
      Hook
    </th>
  </tr>

  <tr>
    <td style="width: 25%;">
      1. __construct
    </td>

    <td style="width: 12.7586%;">
    </td>

    <td style="width: 17.2414%;">
    </td>

    <td style="width: 21.1207%;">
    </td>

    <td style="width: 10.3879%;">
    </td>

    <td style="width: 8.46985%;">
    </td>

    <td style="width: 5.02155%;">
    </td>
  </tr>

  <tr>
    <td style="width: 25%;">
      2. run() (called by par Dispatcher->dispatch)
    </td>

    <td style="width: 12.7586%;">
    </td>

    <td style="width: 17.2414%;">
    </td>

    <td style="width: 21.1207%;">
    </td>

    <td style="width: 10.3879%;">
    </td>

    <td style="width: 8.46985%;">
    </td>

    <td style="width: 5.02155%;">
    </td>
  </tr>

  <tr>
    <td style="width: 25%;">
    </td>

    <td style="width: 12.7586%;">
    </td>

    <td style="width: 17.2414%;">
    </td>

    <td style="width: 21.1207%;">
    </td>

    <td style="width: 10.3879%;">
    </td>

    <td style="width: 8.46985%;">
    </td>

    <td style="width: 5.02155%;">
    </td>
  </tr>
</table>
