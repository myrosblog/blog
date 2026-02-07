---
title: How Web Apps work in ACC (and ctx variable)
categories: [adobe campaign, automation, javascript, neolane, opensource]
---

Web Applications server-side public web pages in Adobe Campaign Classic, created via a drag and drop editor. They are built on top of the ACC JSSP framework and provide access to the workflow `ctx` variable.

<!-- more -->

## How web apps work
An ACC web app is just a visual tool to generate a JSSP page:

![](/assets/images/2019/03/adobe-campaign-web-apps-are-jssp.jpg)

The JSSP code is generated via the XSL template `web-webApp.xsl` which calls `web-core.xsl`, which contains:
```xml
import core.xsl
<xsl:call-template name="serverScriptInit"/>
response.addHeader(Pragma, Cache-Control, Expires, Content-type)
<xsl:call-template name="initActivities"/>
if !g_bNoRendering
  <html>
    <head>
      <meta http-equiv="MSThemeCompatible" content="Yes"/>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <xsl:call-template name="css"/>
      [...]
```

`core.xsl` contains XSL templates such as
```xml
<xsl:template name="serverScriptInit">
<xsl:template name="initActivities">
<xsl:template name="css">
```

## Using the `ctx` variable in the Javascript frontend

Create a dead simple web app with a query on Recipients (named `queryRecipients`) and a page (without transition):

![](/assets/images/2019/03/adobe-campaign-web-app-context-query-page.jpg)

HTML code of the `Page`, using the[ Bootstrap 4 starter template](https://getbootstrap.com/docs/4.3/examples/starter-template/):

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Starter Template · Bootstrap</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.3.1/dist/css/bootstrap.min.css">
  </head>
  <body>
    <nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top"><a class="navbar-brand" href="#">Navbar</a> <button class="navbar-toggler" id="input155197075600849" aria-expanded="false" aria-controls="navbarsExampleDefault" aria-label="Toggle navigation" type="button" data-target="#navbarsExampleDefault" data-toggle="collapse"> <span class="navbar-toggler-icon"></span> </button>
    <div class="collapse navbar-collapse" id="navbarsExampleDefault">
      <ul class="navbar-nav mr-auto">
        <li class="nav-item active"><a class="nav-link" href="#">Home</a></li>
        <li class="nav-item nav-link">Bootstrap 4 starter template</li>
      </ul>
    </div>
    </nav>
    <main class="container mt-5 pt-3"></main>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.3.1/dist/js/bootstrap.min.js" type="text/javascript"></script>
  </body>
</html>
```

The `ctx` variable is an XML created automatically by Adobe Campaign and injected into the HTML. With `_debug` enabled, it is shown in a `<pre>` block:

![](/assets/images/2019/03/adobe-campaign-web-app-context-debug-ctx.jpg)

It is available as a Javascript `DOMElement` in the frontend with `document.controller.ctx`:

![](/assets/images/2019/03/adobe-campaign-web-app-context-as-javascript-variable.jpg)

*See [w3c reference for DOMElement](https://www.w3schools.com/jsref/dom_obj_all.asp)*

<div class="alert alert-danger text-center">
  <strong>DO NOT EXPOSE ANY SENSITIVE DATA IN `CTX` (credentials, server-side data..)</strong>
</div>

## Using the `ctx` variable in the Javascript backend

This `ctx` var can also be used in the backend `Scripts` and in the `Page` itself. Insert in `<main></main>` the following table:
```html
<table class="table table-bordered table-hover table-striped table-sm">
  <thead>
    <tr><th>@firstName</th><th>@lastName</th><th>@email</th></tr>
  </thead>
  <tbody>
    <% for each(var recipient in ctx.queryRecipients.recipient){ %>
    <tr>
      <td><%= recipient.@firstName %></td>
      <td><%= recipient.@lastName %></td>
      <td><%= recipient.@email %></td>
    </tr>
    <% } %>
  </tbody>
</table>
```

Output:

![](/assets/images/2019/03/adobe-campaign-web-app-ctx-list-variables.jpg)

Recap:

![](/assets/images/2019/03/adobe-campaign-web-app-context-show-list.jpg)

## Using `ctx` for interaction between pages

Now that we have a list of recipients, let's display the customer profile of one selected Recipient. First, create a Web app variable which will store the value of the selected recipient id:

![](/assets/images/2019/03/adobe-campaign-web-app-variable-recipientId.jpg)

To enable transitions and interactions between pages, the page must contain a `<form id="page-form>">`. Insert it in the `<main`:
```html
<main>[...]</main>
```
becomes
```html
<main><form method="post" name="page" id="page-form">[...]</form></main>
```

Add a transition named `transition1`, connected to a query where `@id = $([vars/recipientId])` and another page:

![](/assets/images/2019/03/adobe-campaign-web-app-ctx-show-recipient.jpg)


In the first page, add a new `<td>` with a Button as follow:
```html
<td>
  <a href="#" class="btn btn-sm btn-primary"
    onclick="
      document.controller.setValue('/ctx/vars/recipientId', '<%= recipient.@id %>'); // make sure to wrap the recipient-id in quotes, otherwise the ACC editor will throw a JS error)
      document.controller.submit('next', '_self', 'transition1');">
    Show
  </a>
</td>
```

This is made possible via the `setValue(path, value)` and `getValue(path)` functions of `document.controller` which is a `UIController`:

![](/assets/images/2019/03/adobe-campaign-web-app-context-controller-get-set-value.jpg)

and `submit(formAction, formTarget, transitionName)`:
```js
/**
 * Inject an <input name="ctx"> in the <form id="page-form">,
 * Then submits the form
 *
 * @param strAction      can be any of none|refresh|next|previous
 * @param strTarget      can be any of the HTML attribute target _blank|_self|_parent...
 * @param strTransition  name of the transition to call in case of accAction=next
 * @param bForceNoFile   file are already uploaded, don't reupload it
 * @param bNoWait        don't display waiting box
 */
UIController.prototype.submit = function(strAction, strTarget=null, strTransition=null, bForceNoFile=null, bNoWait=null){};
```


Save, refresh, click on Show and you'll get this:

![](/assets/images/2019/03/adobe-campaign-web-app-ctx-show-recipient-html.jpg)

![](/assets/images/2019/03/adobe-campaign-web-app-ctx-show-recipient-xml.jpg)

For both pages, download [the HTML codes on gist.github.com](https://gist.github.com/myrosblog/3e67f996ce2552fb46ad479922f9a83e).

## Update a recipient based on `ctx.recipient.@id`

```js
var now = formatDate(new Date(), "%4Y-%2M-%2D %02H:%02N:%02S")

xtk.session.Write(
  <recipient xtkschema="nms:recipient" _operation="update" _key="@id" id={ctx.recipient.@id}
    lastModified={now}
    firstName="New first name"
  />
);

// equivalent to:
var recipient = NLWS.nmsRecipient.load(ctx.recipient.@id);
recipient.firstName = "New first name";
recipient.save();
```

## Use images and enum
```js
<%= NL.route('nms:task.png', 'reverse_img') %> // '/nms/img/task.png'

/**
 * Given a list of <enumValue>, return img using name
 *
 * @param enum XML, <node><enumValue img="nms:canceled.png" name="canceled"/><enumValue img="nms:task.png" name="todo"/></node>
 * @param enumName string, 'canceled'
 *
 * @example getEnumFieldWithName(<node><enumValue img="nms:canceled.png" name="canceled"/><enumValue img="nms:task.png" name="todo"/></node>, 'canceled', 'img') // nms:canceled.png
 */
function getEnumFieldWithName(enum, enumName, enumField){
  for each(var e in enum.enumValue){
    if(e.@['name'] == enumName){
      return e.@[enumField];
    }
  }
  return '';
}
<%= getEnumFieldWithName(ctx.queryEnumClientelingStatus, task.@status2, 'img') %> // nms:canceled.png

<img class="nlui-widget" src="<%= NL.route(getEnumFieldWithName(ctx.queryEnum, aVariableHere, 'img'), 'reverse_img') %>"/>
```

## Use `NL.QueryDef` to execute client-side SOAP calls in Javascript from the browser
Can be used to create a Single Page App (SPA) for specific goals, such as a read-only view of recipients, with filters, orders, etc. 

⚠️ the result is in XML format. For JSON format see next chapter.
```js
var queryDef = new NL.QueryDef("nms:recipient", NL.QueryDef.prototype.OPERATION_SELECT);
queryDef.addSelectExpr("@id"); // add the column @id to the select clause
queryDef.addSelectExpr("@firstName", "@newAttr"); // set @firstName as an attr named "newAttr" in the result XML
queryDef.addSelectExpr("@lastName", "newNode"); // set @lastName as a node named "newNode" in the result XML
queryDef.setLineCount(2); // SQL LIMIT
queryDef.setStartLine(10); // SQL OFFSET
queryDef.setShowSQL(true); // create a <dataSQL>SELECT x,y from Z</dataSQL> node in <recipient-collection>
queryDef.addWhereConditionExpr("@email = '"+email+"'");
var callback = {
  onXtkQueryCompleted: function(queryDef, res, error) {
    console.log('Recipients found!', res); // see below for res output
  }
};
queryDef.execute(NL.session.serverURL + "/nl/jsp/soaprouter.jsp", '', callback);
```

Output, `res` content:

```xml
<recipient-collection>
  <recipient id="1" newAttr="Jane"><newNode>Doe</newNode></recipient>
  <recipient id="2" newAttr="John"><newNode>Doe</newNode></recipient>
  <dataSQL>
    SELECT   R0.iRecipientId, R0.sFirstName, R0.sLastName FROM NmsRecipient R0 WHERE (R0.sEmail = E'x@y.z') LIMIT 2 OFFSET 10
  </dataSQL>
</recipient-collection>
```

Above code taken from `nl6/web/core/dce/contentEditor.js` `loadFromTemplateId: function(templateId)`.

Doc for `queryDef.execute()` @ `nl6/web/code/queryDef.js`:
```js
/** Do the soap call
 * @strUrl : soap router url
 * @sessionToken
 * @asyncTarget : enable the asynchronious mode and define the objet to
 *                notify. That object must implement a onXtkQueryCompleted()
 *                method.
 */
NL.QueryDef.prototype.execute = function(strUrl, sessionToken, asyncTarget)
```

## Use `POST /xtk/queryList.jssp` to get objects in Javascript from the browser
Calling `\datakit\xtk\fra\jssp\queryList.jssp` with a POST param `queryDef` containing a JSON as an urlencoded string:

```js
var postData = {
   "operation":"select", "schema":"xtk:workflow",
   "startLine":0, "lineCount":30,
   "select":{
      "node":[
        {"expr":"[.]", "alias":"@cs"},
        {"expr":"@label", "alias":"@label"},
        {"expr":"[process/@startState]", "alias":"@startState", "enabledIf":"HasPackage('nms:campaign')"},
      ]
   },
   "where":{
      "condition":[{"expr":"@isModel=0"}]
   },
   "orderBy":{
      "node":[{"expr":"@lastModified", "sortDesc":true}]
   },
};
$.post("/xtk/queryList.jssp", {queryDef:encodeURIComponent(JSON.stringify(postData))}, function(response) {
  console.log(response); // {data: Array(30), needPagination: true}
  console.log(response.data); // [{cs: " ()", label: "", startState: "0", _schema: "xtk:workflow"}]
});
```
