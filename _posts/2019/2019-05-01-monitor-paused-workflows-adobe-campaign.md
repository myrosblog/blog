---
title: Monitor paused Workflows on Adobe Campaign
categories: [opensource,adobe campaign]
---

Send a daily alert if some of your critical workflows are not running (status is paused, failed, restart required..).

<p class="text-center">⚙️🛑📧</p>

<!--more-->

## Overview
The workflow runs daily @ 9AM and check against a whitelist of workflows that need to be up and running every day. If some workflow are not in the "Started" state, an email is sent with data such as Label, Last run date, Folder, etc.

![](/assets/images/2019/05/adobe-campaign-monitor-workflows-email.jpg)

## Workflow set up
The workflow consists of a Scheduler, a Query on workflows, a Javascript activity and an Email Alert:

![](/assets/images/2019/05/adobe-campaign-monitor-workflows-workflow.jpg)

## Query set up
The query is based on `xtk:workflow`, where the `state` is different from `Started` and the `internalName` is in a whitelist with `OR` conditions:

![](/assets/images/2019/05/adobe-campaign-monitor-workflows-query.jpg)

Use additional data to add the columns you need to display:

![](/assets/images/2019/05/adobe-campaign-monitor-workflows-additional-data.jpg)

You can use `@folderLabel` for the Folder Label alias.

## Test activity set up
The test activity performs a simple test on `vars.recCount > 0` without the default connection:

![](/assets/images/2019/05/adobe-campaign-monitor-workflows-test.jpg)

## Javascript activity
The JS builds an HTML table based on the query results:
```js
var query = NLWS.xtkQueryDef.create({queryDef: {
  schema: vars.targetSchema, operation: "select",
  select: { node: [
    {expr: "@internalName"},
    {expr: "@label"},
    {expr: "@folderLabel"},
    {expr: "@lastStart"},
    {expr: "@state"},
  ]},
  orderBy: { node: [{expr:"@label", sortDesc:"false"}] }
}});
var records = query.ExecuteQuery();

vars.htmlEmail = '';
vars.htmlEmail += '<table border="1"><thead>';
vars.htmlEmail += '<tr><th>internalName</th><th>Label</th><th>State</th><th>Last Start</th><th>Folder</th></tr>';
vars.htmlEmail += '</thead><tbody>';
for each(var record in records.getElements()){
  vars.htmlEmail += '<tr>';
  vars.htmlEmail += '<td>'+record.$internalName+'</td>';
  vars.htmlEmail += '<td>'+record.$label+'</td>';
  vars.htmlEmail += '<td>'+record.$state+'</td>';
  vars.htmlEmail += '<td>'+record.$lastStart+'</td>';
  vars.htmlEmail += '<td>'+record.$folderLabel+'</td>';
  vars.htmlEmail += '</tr>';
}
vars.htmlEmail += '</tbody></table>';
```
*More details on the queryDef object on the [queryDef toolbox tutorial]({% post_url adobe-campaign/2018-08-03-querydef-database-toolkit %}).*

## Email activity

The email uses `vars.recCount` and `vars.htmlEmail`:
```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
</HEAD>
<BODY>
<P>Hi,</P>
<P>This is to notify you that&nbsp;following workflows are STOPPED on <%= formatDate(new Date(), "%4Y/%2M/%2D") %>.</P>
<P><STRONG>List of non running workflows</STRONG>:<BR><%= vars.htmlEmail %></P>
<P>Please make sure that those workflows are <STRONG>always</STRONG> 
running.</P>
<P>Thanks.</P>
</BODY></HTML>
```

Reference:
- https://docs.campaign.adobe.com/doc/AC/en/WKF_Use_cases_Supervising_workflows.html

Update: Javascript activity can be reduced to a simple SQL call, then the Email uses `new XML(vars.records)`, see https://docs.campaign.adobe.com/doc/AC/en/WKF_Use_cases_Sending_personalized_alerts_to_operators.html

Delete the JS activity. In the advanced tab of the Alert:
```js
var query = NLWS.xtkQueryDef.create({queryDef: {
  schema: vars.targetSchema, operation: "select",
  select: { node: [
    {expr: "@field1"},
    {expr: "@field2"},
  ]},
//  orderBy: { node: [{expr:"@label", sortDesc:"false"}] }
}});
var records = query.ExecuteQuery(); // DOMElement
vars.records = records.toXMLString() // serialization as a string
  .replace(/query-collection/g, 'collection'); // needed because <query-collection> is an invalid node name
```

In the HTML Source tab of the Alert:
```html
<TABLE>
  <THEAD>
  <TR>
    <TH>field1</TH><TH>field2</TH></TR></THEAD>
  <TBODY><%
var records = DOMDocument.fromXMLString(vars.records);
for each (var record in records.root.getElements()){ %> 
  <TR>
    <TD><%= record.$field1 %></TD>
    <TD><%= record.$field2 %></TD>
  </TR><%
 } %></TBODY></TABLE>
```
