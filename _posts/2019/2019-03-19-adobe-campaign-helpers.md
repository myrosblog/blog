---
title: Adobe Campaign Javascript helpers for Workflows
categories: [opensource,adobe campaign,tools,javascript,helpers,snippets]
---

Javascript helpers for JSSP, Javascript in workflows and JST in Adobe Campaign, grouped by domains such as SQL, Linux, FTP or Currency.

<p class="text-center">🐍👑🌍</p>
<!--more-->

## SQL helpers

```js
/**
 * Performs an SQL INSERT INTO (no SQL injection protection /!\)
 * @param {object} fields {column1:value1, column2:value2}
 * @returns {number} The number of inserted fields
 * @see sqlExec
 */
function insertInto(table, fields, log){
  if(undefined === log){
    log = false;
  }
  var columns = Object.keys(fields).join(', ');
  var values = Object.keys(fields).map(function(key) {
    var value = fields[key];
    // if it's a string
    // - remove all ' with regex /'/g
    // - wrap with single-quote
    if(typeof(value) == 'string'){
      value = value.replace(/'/g, "");
      value = "'"+value+"'";
    }
    // if it's null, use 'null'
    else if(value == null){
      value = 'null';
    }
    return value;
  }).join(', ');
  var sql = "INSERT INTO "+ table + " ("+columns+") VALUES ( "+values+" )";
  if(log){
    logInfo('Executing '+sql)
  }
  return sqlExec(sql);
}
/**
 * @param {string} tableName ex: 'nms:recipient'
 * @param {NLSchema} srcSchema ex: NLWS.nmsecipient
 * @param {Object} params
 * @param {array} params.where example: [{expr: "@a>1"}, {expr: "@b is null"}]
 * @param {array} params.orderBy example: [{expr: "@id", sortDesc: "false"}]
 */ 
function getOneOrNull(tableName, srcSchema, params){
  var query = NLWS.xtkQueryDef.create({queryDef: {
    schema: tableName,
    operation: "get", 
    select: { node: [
      {expr: "@id"},
    ]},
    where: { condition: []}, 
    orderBy: { node: []}
  }});
  params.where.condition = params.where;
  if(params.orderBy){
    
  }
  var res = query.ExecuteQuery();
  return srcSchema.load(res.@id);
}
```

## Linux server helpers
```js
/**
 * Helper for the ACC execCommand() function
 * @param {string} command the linux command to execute
 * @param {Object} params parameters [to be flexible for evolutions]
 * @param {bool} params.logTheCall if true, calls logInfo(command) (default to true)
 * @param {bool} params.logTheOutput if true, send the output to logInfo (default to true)
 * @param {bool} params.throwOnError if true, throws an exception if linuxResultCode is != 0 (default to false)
 *
 * @return {Object}
 * @return {int} return.linuxResultCode the linux result code (0 = success), returned by standard JSAPI execCommand function
 * @return {string} return.rawOutput the linux standard output as a unique string, returned by standard JSAPI execCommand function
 * @return {string[]} return.lines the linux standard output as an array of lines (lines split by \n)
 *
 * @example
 * exec('pwd')
 * exec('mkdir -p /a/b/c', {logTheCall:false})
 * exec('mktemp -d', {logTheOutput:false, throwOnError: true}) 
 */
function exec(command, params){
  if(undefined == params){
    params = {};
  }
  var logTheCall = params.logTheCall || true;
  var logTheOutput = params.logTheOutput|| true;
  var throwOnError = params.throwOnError || false;
  
  if(logTheCall){
    logInfo('grl:helpers | executing | '+command);
  }
  var result = execCommand(command, !throwOnError); // @return [linux result code, output]
  var lines = result[1].split("\n");
  if(logTheOutput){
    for each (var line in lines){ 
      logInfo("" + line);
    }
  }
  return {linuxResultCode: result[0], rawOutput: result[1], lines: lines};
}

/**
 * Calls unix sed to replace a text by another text, in a file
 * Usage of sed: 
 * - sed -i s/regular-expression/replacement-text/flags
 * - -i replace in file instead of in string
 *
 * @param {string} replaceThis the regex to look for
 * @param {string} byThis the string write instead
 * @param {string} inThisFile full path of the file
 * @param {Object} params for exec() params
 *
 * @see https://doc.ubuntu-fr.org/sed
 *
 * @example
 * replaceInFile(',', ';', '/a/b/c/my.csv', {logTheCall:true})
 *
 * @todo replace | by [|] because pipe | in the sed regex must be escaped with [|]
 */
function replaceInFile(replaceThis, byThis, inThisFile, params){
  var command = "sed -i 's/"+replaceThis+"/"+byThis+"/g' '"+inThisFile+"'";
  return exec(command, params);
}

/**
 * Remove carriage returns '\r' in file
 * @param {string} fileFullpath the full path of the file
 * @param {Object} params for exec() params
 */
function removeCarriageReturn(fileFullpath, params){
  replaceInFile('\r', '', fileFullpath, params)
}

/**
 * Helper for the ACC execCommand() function
 * @author Myros
 * Documentation {@link https://myrosblog.com/2019/03/adobe-campaign-helpers}
 * @version 1.0.0 
 * @param {string} command the linux command to execute
 * @param {object} params
 * @param {bool} params.logTheCall if true, calls logInfo(command) (default to true)
 * @param {bool} params.logTheOutput if true, send the output to logInfo (default to true)
 * @param {bool} params.throwOnError if true, throws an exception if linuxResultCode is != 0 (default to false)
 *
 * @example
 * sh.exec('pwd'); // print working directory
 * sh.exec('mkdir -p a/b/c', {logTheCall:false}); // create folder (with parents if needed)
 * sh.exec('mktemp -d', {logTheOutput:false, throwOnError: true}); // createa a temp folder
 */
var sh = {
  // vars for defaults & instance usage
  logTheCall: true,
  logTheOutput: true,
  throwOnError: false,
  // exec()
  exec: function(command, params){
    var _this = this; // cache this
    if(undefined == params){
      params = {};
    }
    var logTheCall = undefined != params.logTheCall ? params.logTheCall : _this.logTheCall;
    var logTheOutput = undefined != params.logTheOutput ? params.logTheOutput : _this.logTheOutput;
    var throwOnError = undefined != params.throwOnError ? params.logTheOutput : _this.throwOnError;
    if(logTheCall){
      logInfo('sh.exec: '+command);
    }
    var result = execCommand(command, !throwOnError); // @return [linux result code, output]
    var lines = result[1].split("\n");
    if(logTheOutput){
      for each (var line in lines){ 
        logInfo("" + line);
      }
    }
    return {linuxResultCode: result[0], rawOutput: result[1], lines: lines};
  }
};
```

## FTP folders
```js
/***
 * All the following functions return a string ending with /
 */
/**
 * @return {string} the FTP incoming folder
 */
function getIncoming(){
  return '/sftp/myinstance/incoming/';
}
function getVendor1Incoming(){
  return getIncoming()+'vendor1/';
}
function getVendor1Archive(){
  return getIncoming()+'vendor1/archive/';
}
function getVendor2Incoming(country){
  return getIncoming()+'vendor2/'+country.toLowerCase()+'/';
}
function getVendor2Archive(country){
  return getVendor2Incoming(country)+'archive/'+formatDate(new Date(), '%4Y/%2M')+'/';
}
```

## Log helpers
```js
function LogInfo(){
  var args = Array.prototype.slice.call(arguments); // convert arguments to an array-like, @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/arguments#Description
  args.unshift('[ACME '+application.buildNumber+' LogInfo] ['+application.operator.login+']: '); // add prefix with brand name, version, type and operator login
  logInfo.apply(null, args); // call standard logInfo() with apply(), @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/apply
}

LogInfo('loading file XXX'); // [ACME 4444 LogInfo] [my_login] loading file XXX
LogInfo();                   // [ACME 4444 LogInfo] [my_login]
LogInfo(null);               // [ACME 4444 LogInfo] [my_login] null

function LogWarning(){
  var args = Array.prototype.slice.call(arguments); // convert arguments to an array-like, @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/arguments#Description
  args.unshift('[ACME '+application.buildNumber+' LogWarning] ['+application.operator.login+']: '); // add prefix with brand name, version, type and operator login
  logWarning.apply(null, args); // call standard logWarning() with apply(), @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/apply
}
```

## Adobe Campaign
```js
/**
 * @class DistributionOfValues
 * @param schema
 * @param field
 */
function DistributionOfValues(schema, field){
  this.queryDef = {
    operation: 'select', lineCount: 200, schema: schema,
    select: {node:[
      {alias: '@expr', expr: field, groupBy: 'true', noSqlBind: 'true'},
      {alias: '@count', expr: 'COUNT()', label: 'Count'},
    ]},
    orderBy: {node: [
      {expr: 'COUNT()', sortDesc: 'true'},
    ]},
  };
  /**
   * @return XML list
   */
  this.get = function(){
    this.results = NLWS.xtkQueryDef.create({queryDef:this.queryDef}).ExecuteQuery();
    return this.results.getElements();
  }
}
// Usage:
var d = new DistributionOfValues('nms:recipient', '[location/@countryCode]');
d.queryDef.where = {condition: [
  {expr: 'DateOnly([creationInfo/@grlCreationDate]) = #2019-08-26#'},
]};
for each(var record in d.get()){
  logInfo(record.$expr + record.$count);
}

/**
 * @param schema string
 * @param enumName string
 * @example getEnum('nms:recipient', 'gender'); // The 'gender' Enumeration from the nmsRecipient schema
 * @return Enumeration class or null
 */
function getEnum(schema, enumName){
  var enums = application.getSchema(schema).enumerations;
  for each(var enum in enums){
    if(enum.name === schema + ':' + enumName){
      return enum;
    }
  }
  return null;
}

/**
 * @since 20190906
 * @param schema string
 * @param enumName string
 * @param valueValue string
 * @example getEnumLabelByValue('nms:recipient', 'gender', '2'); // 'Female'
 * @return label string or null
 */
function getEnumLabelByValue(schema, enumName, valueValue){
  var values = getEnum(schema, enumName).values;
  for each(var value in values){
    if(value.value === valueValue){
      return value.label;
    }
  }
  return null;
}
```

## Currency, money, price
```js
/**
 * Format a price to always have 2 decimals
 * @example
 * formatPrice('12.3') = '12.30'
 *
 * @param {xml|string|int|float} p  the price to format
 * @return {string} the formatted price
 */
function formatPrice(p){
  if(typeof p == 'xml'){
    p = p.toString();
  }
  if(typeof p == 'string'){
    p = parseFloat(p);
  }
  return p.toFixed(2);
}
```

## Alert Email Footer
```js
/**
 * function that returns html footer for Alert emails with system informations
 * @param instance
 * @param event
 * @return string
 */
 function getEmailFooterSystemInformation(instance, event){
  var style = '<style>'+
    '.table-footer-system{ border-collapse: collapse; }'+
    '.table-footer-system th { background: #5B9BD5; padding: 7px 15px; color: white; }'+
    '.table-footer-system td, .table-footer-system th { border-color: #2B6093; }'+
    '.table-footer-system td { padding: 5px; }'+
    '.error { color: red; }'+
  '</style>';
  var folder = NLWS.xtkFolder.load(instance.folder_id);
  var campaign = (instance.operation_id > 0) ? NLWS.nmsOperation.load(instance.operation_id) : {};
  var table = '<table class="table-footer-system" border="1">'+
    '<thead>'+
      '<tr>'+
        '<th>Workflow label</th>'+
        '<th>Workflow name</th>'+
        '<th>Folder</th>'+
        '<th>Event date</th>'+
        '<th>Event id</th>'+
        '<th>Task id</th>'+
        '<th>Activity label (name)</th>'+
        '<th>Campaign label</th>'+
        '<th>Campaign name</th>'+
        '<th>Last error<span class="error">*</span></th>'+
        '<th>File name<span class="error">*</span></th>'+
        '<th>Table name<span class="error">*</span></th>'+
        '<th>Instance @ version</th>'+
      '</tr>'+
    '</thead>'+
    '<tbody>'+
      '<tr>'+
        '<td>'+instance.label+'</td>'+
        '<td>'+instance.internalName+'</td>'+
        '<td>'+folder.fullName+'</td>'+
        '<td>'+formatDate(event.processingDate, "%4Y/%2M/%2D %2H:%2N:%2S")+'</td>'+
        '<td>'+event.eventIdentifier+'</td>'+
        '<td>'+task.taskIdentifier+'</td>'+
        '<td>'+activity.label+' ('+activity.name+')</td>'+
        '<td>'+campaign.label+'</td>'+
        '<td>'+campaign.internalName+'</td>'+
        '<td>'+(vars.lastError || '')+'</td>'+
        '<td>'+(vars.filename || '')+'</td>'+
        '<td>'+(vars.tableName || '')+'</td>'+
        '<td>'+application.hostName+' @ '+application.buildNumber+'</td>'+
      '</tr>'+
    '</tbody>'+
    '<tfoot>'+
      '<tr>'+
        '<td colspan="99"><span class="error">*</span> indicates fields that may be empty.</td>'+
      '</tr>'+
    '</tfoot>'+
  '</table>';
  var editThisCode = '<p><span style="font-size:10px">Edit this footer in "Administration > Configuration > Javacript codes > :helpers"</span></p>';
  return style+"<HR>"+
    "<P>System information:</P>"+
    "<P>"+table+"</P>"+editThisCode
  ;
}
```

![](/assets/images/2019/09/adobe-campaign-javascript-email-alert-footer-html-render.jpg)

![](/assets/images/2019/09/adobe-campaign-javascript-email-alert-footer-workflow-configuration.jpg)
