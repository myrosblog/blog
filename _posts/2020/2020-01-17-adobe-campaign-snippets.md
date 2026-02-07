---
title: Snippets for Adobe Campaign (JavaScript, XML, SQL)
categories: [opensource,adobe campaign]
---

Excerpt here...

<p class="text-center">🐍👑🌍</p>

<!--more-->

**bold** *italic*  ~~strikethrough~~

## HTML: if/else if/else in JavaScript Template (& gender)
```html
{% raw %}
<td>
  <% if(recipient.gender == 1){ %>
    <!-- Woman -->
  <% }else if(recipient.gender == 2){%>
    <!-- Man -->
  <% }else{ %>
    <!-- Unspecified -->
  <% } %>
</td>
{% endraw %}
```

## XML in JavaScript
### DOMDocument.load
```js
var xmlDoc = DOMDocument.load(vars.filename);
var entries = xmlDoc.getElementsByTagName('entry');
logInfo(entries.length);
for each(var entry in entries){
	  logInfo(entry.getValue('g:image_link'));
	  var sql = "INSERT INTO "+vars.tableName+" (iId, sProductId) VALUES ($(id), 'a')";
	  var recCount = sqlExec(sql);
	  logInfo('('+recCount+')', sql);
}
```
### DOMDocument.fromXMLString
```js
try {
  var mData = sqlGetMemo('SELECT mData FROM nmsDelivery WHERE iDeliveryId = $(l)', record.$id); // get memo from DB, @return string
} catch (error) {
  continue;
}
var doc = DOMDocument.fromXMLString(mData); // convert to DOMDocument
var subject = doc.root.getValue('mailParameters/subject'); // root is a DOMElement and getValue @return string
var cleanedSubject = subject;
cleanedSubject = cleanedSubject.replace(/(\r\n)/gm, ''); // remove line breaks
```

## SQL: Adobe Campaign audit trail for Schemas

Will create 4 fields: `@created` & `@lastModified` (datetime), `@createdBy-id` & `@modifiedBy-id` (long). Will be automaticaly updated at record creation & update with the `Update data` activity. Use `Advanced>Disable audit` to disable the update of those fields.

Best practice: Use it for any table with less than 10,000 records.

XML for Schema:
```xml
<!-- audit -->
<element aggregate="xtk:common:auditTrail" name="auditTrail"/>
```

JS for data migration in SQL:
```js
var tables = ['customAbc','customDef',];
for each(var table in tables){
  var sql = 'UPDATE '+table+' SET tsLastModified=oldField, tsCreated=oldField';
  logInfo(sql);
  var count = sqlExec(sql);
  logInfo('> '+count+' records updated');
}
```

## UI: Filtering
```console
0|@created|#2020-01-30 23:00:00.000Z#|>=|||||0|/|0
0|@blackList|0|=|AND||||0|/|0
0||||AND||||1|/|0
0|@email|'%@%.%'|LIKE|||||0|/|1
0|@mobilePhone||IS NOT NULL|OR||||0|/|1
```

![todo](/assets/images/2020/01/20200117-160032-screenshot-7.jpg)

## JS: Select raw data from workflow transition
```javascript
var query = NLWS.xtkQueryDef.create({queryDef: {
  schema: vars.targetSchema, operation: 'select', lineCount: 999999999, // /!\ lineCount defaults to 10,000
  select: { node: [
    {expr: '@id'},
    {expr: '@email'},
  ]},
}});
var records = query.ExecuteQuery(); // DOMElement

for each(var record in records.getElements()){
  logInfo(record.$id);
  var cleanedEmail = record.$email.replace(/\s+/g, '').toLowerCase();
  sqlExec("UPDATE "+vars.tableName+" SET sEmail=$(sz) WHERE iId=$(l)", cleanedEmail, record.$id);
}
```

## Insert raw data in workflow
```js
```

## JS: Import libraries
```js
loadLibrary(<namespace>:<name>);
loadLibrary('xxx:yyy');
```

## JS: Data Quality Management (DQM) with XTK expression
```js
var xtkFields = ['@email', '@mobilePhone', '@phone', '@firstName', '@lastName', '@middleName', ];
xtkFields = xtkFields.map(function(x){return 'COALESCE('+x+', \'\')';}); // [COALESCE(@email, ''), COALESCE(@firstName, '')...]
xtkFields = xtkFields.join('+'); // "COALESCE(@email, '')+COALESCE(@firstName, '')...]"
var query = NLWS.xtkQueryDef.create({queryDef: {
  schema: 'nms:recipient', operation: 'select', lineCount: 999999999, // /!\ lineCount defaults to 10,000
select: { node: [{expr: "@id"}, {expr: xtkFields, alias: '@text'}] },
  where: { 
    condition: [
      {expr: xtkFields+" LIKE '%<%'", boolOperator: 'OR'}, // look for <
      {expr: xtkFields+" LIKE '%>%'", boolOperator: 'OR'}, // look for >
      {expr: xtkFields+" LIKE '%&%'", boolOperator: 'OR'}, // look for &
    ],
  }
}});
var records = query.ExecuteQuery(); // DOMElement
for each(var record in records.getElements()){
  logInfo(record.$id, record.$text);
}
```

## JS: Data Quality Management (DQM) with SQL expression
```js
var sqlFields = ['sEmail', 'sMobilePhone', 'sPhone', 'sFirstName', 'sLastName', 'sMiddleName', ];
var sql = 'SELECT iRecipientId FROM NmsRecipient WHERE '+
  'CONCAT('+sqlFields.join(',')+') LIKE \'%<%\' OR '+
  'CONCAT('+sqlFields.join(',')+') LIKE \'%>%\' OR '+
  'CONCAT('+sqlFields.join(',')+') LIKE \'%&%\' '
;
var document = sqlSelect('document,@id:long', sql);
logInfo(document); // <select> <document id="XXX"/> </select>
```

## XTK: Case/When
```js
Case(
  When([target/@nature] = 'transactional', [target/@created]),
  When([target/scheduling/@extracted] != '', [target/scheduling/@extracted]),
  When([target/scheduling/@contactDate] != '', [target/scheduling/@contactDate]),              
  Else('')
)
```

## JS: JSON
```js
// Get the object you want to print
var myObject = {
  name: "Example Object",
  property1: "value1",
  property2: 123,
  property3: true
};

// Convert the object to a JSON string
var jsonString = JSON.stringify(myObject, null, 2); // Use null and 2 for pretty printing
```

## JS: Dates
```js
formatDate(getCurrentDate(), '%4Y%2M%2D-%2H%2N%2S'); // "20190430-150837" for folder names

<%= formatDate(getCurrentDate(), '%4Y%2M') %> // "202005" for delivery labels [scenario/@useLabelScript]
```

## JS: Working with options and current month
```js
var month = formatDate(getCurrentDate(), '%2M'); // 01, 02, 03...
var optionName = 'myOptionName_'+month;
logInfo('Getting option:', optionName);
var optionValue = getOption(optionName);
setOption('otherOption', optionValue);
```

## JS: Change Continuous Delivery activity XML settings via Javascript
```js
var month = formatDate(getCurrentDate(), '%2M'); // 01, 02, 03...
var internalName = 'myInternalName_'+month;
var query = NLWS.xtkQueryDef.create({queryDef: {
  schema: "nms:delivery", operation: "get", // "get" does a SQL "LIMIT 1"
  select: { node: [{expr: '@id'}] }, // get @id only
  where: { 
    condition: [
      {expr: "@internalName = '"+internalName+"'"},
    ],
  }
}});
var deliveryTemplate = query.ExecuteQuery();
logInfo('activity.scenario_id:', deliveryTemplate.$id);
activity.scenario_id = deliveryTemplate.$id;
```

## JS: `vars` with array

```js
vars.markets= [
 //'US',
 'GB',
 'FR',
];
vars.market = vars.markets.split(',')[0];
```

## JS: Create temporary linux file

```js
vars.filename = execCommand('mktemp')[1]+'-'+formatDate(new Date(), '%4Y-%2M-%2D')+'-ac7.csv'
```

## JS: Asynchronous HTTP calls

For details, please check [Async API calls in Adobe Campaign]({% post_url 2021/2021-01-08-async-api-calls-in-adobe-campaign %})

```js
var records = ...; // must be set
var requests = []; // use to store all HttpClientRequest for "HttpClientRequest.wait(requests)"

var onComplete = function(request, context, status){
  // do your things
  sendNext(context);
}

function sendNext(context) {
  while(records.length != 0) { // while list is not empty
    var record = records.shift(); // take and remove first record
    var req = new HttpClientRequest(endpoint);
    req.complete = onComplete;
    try {
      var hasProxy = false;
      var async = true;
      var timeout = 2000;
      req.execute(hasProxy, async, timeout, context);
      requests.push(req);
      return; // important
    } catch(error){
      logWarning('Error while getting response, continue. Error:', error);
      continue; // continue because not called by onComplete
    }
  }
} 

// Start N requests with context as a JSON
sendNext({id: 1});
sendNext({id: 2});

// Wait until all requests are completed
HttpClientRequest.wait(requests);
```
