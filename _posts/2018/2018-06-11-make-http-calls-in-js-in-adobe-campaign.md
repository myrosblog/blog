---
title: Make HTTP calls in JS in Adobe Campaign
categories: [adobe campaign,neolane]
redirect_from: /2018/06/make-http-calls-in-js-in-adobe-campaign/
---

<!-- more -->

## Introduction

For any of the below calls, the URLs you want to call must be whitelisted in `/usr/local/neolane/nl6/conf/serverConf.xml` inside the node `/serverConf/shared/urlPermission` as a node `<url dnsSuffix="" urlRegEx=""/>`:
```xml
<serverConf>
  <shared>
    <urlPermission>
      <url dnsSuffix="domain-name-here.com" urlRegEx="https://.*"/>
      <url dnsSuffix="domain-name-here.com" urlRegEx="http://.*"/>
      <url dnsSuffix="sub.domain.com" urlRegex="https://.*"/>
    </urlPermission>
  </shared>
</serverConf>
```

*Note: if you are on a hosted instance, see the [tutorial to connect through SSH]({% post_url 2019/2019-02-14-enable-ssh-adobe-campaign %}) to execute maintenance on server.*

If you don't whitelist your target URLs you'll get a JS Exception:
```console
02/15/2019 11:37:29 AM		Workflow 'WKF471' is being run
02/15/2019 11:37:29 AM	js	SCR-160012 JavaScript: error while evaluating script 'WKF471/js'.
02/15/2019 11:37:29 AM	js	JST-310026 The URL 'https://jsonplaceholder.typicode.com/users/1' that the script is trying to access is not part of the authorized addresses in urlPermission (serverconf.xml)
```

## Simple HTTP GET

```js
var url = 'https://jsonplaceholder.typicode.com/users/1';
var req = new HttpClientRequest(url);
req.execute();
var resp = req.response;
var user = JSON.parse(resp.body)
logInfo(user.name) // "Leanne Graham"
```

## HTTP GET with params `?var1=1&var2=2`

```js
var base = 'https://jsonplaceholder.typicode.com/posts'

var params = {
  'postId': 1,
  'userId': '1'
};

// then convert them to a URL format var1=1&var2=2
var query = Object.keys(params)
    .map(function(k){ return k + '=' + params[k] })
    .join('&');

var url = base+'?'+query // https://jsonplaceholder.typicode.com/posts?userId=1&id=1

var req = new HttpClientRequest(url);
req.execute();
var resp = req.response;
var posts = JSON.parse(resp.body)
logInfo(posts[0].id) // 1
```

## HTTP POST as form
```js
var req = new HttpClientRequest('https://url.com/page-with-form');
req.method = 'POST';
req.body = 'var1=hello@fresh.com&var2=4324f83488dwq84dw4e84dw4dew84';
req.header["Content-Type"] = "application/x-www-form-urlencoded";
req.execute();
var response = req.response;

if(response.code != 200){
  logError('Server returned not HTTP 200: HTTP', response.code, response.body);
}

var body = ''+response.body; // convert to string
logInfo('HTTP response body', body);
```

## HTTP Basic Authentication

```js
var http = new HttpClientRequest("http://www.somewhere.com/login")

var buffer = new MemoryBuffer()
buffer.fromString("MyLogin" + ':' + "MyPassword", "iso-8859-1")

http.header["Authorization"] = "Basic " + buffer.toBase64()
http.header["Content-Type"] = "text/xml; charset=utf-8"

http.method = "SEARCH"
http.body = "<xml>any content</xml>"

http.execute()
```

## Asynchronous HTTP query

```js
/**
 * @param hasProxy: Boolean to true if you need to use a proxy HTTP. By default set to false.
 * @param async: Boolean set to true if the query is asynchronous. Set to false by default.
 * @param context: The context is any object that will be forwarded to the second argument of the complete function in case of an asynchronous query. Set to null by default.
 * @param timeout: Maximum wait time in milliseconds in case of an asynchronous query. If this parameter isn't defined, the wait time is 5 minutes.
 */
function execute(hasProxy=false, async=false, context=null, timeout=300000)
```

```js
// get records from previous transition
var query = NLWS.xtkQueryDef.create({queryDef:{ [...] }}); // @see /2018/08/use-querydef-the-database-toolkit-in-adobe-campaign#select-raw-data-from-workflow-transition
var records = query.ExecuteQuery().getElements();

var successRequests = []; // used to store successfuly HttpClientRequest for "HttpClientRequest.wait(requests)"
var failedRequests = []; // used to store failed HttpClientRequest, if a retry is needed

// function called after each async API call
var onComplete = function(req, context, status){
  // compute the response: get data from var xmlDoc = DOMDocument.fromXMLString(String(resp.body)); then sqlExec(...)
  // call next
  sendNext(context);
}

// for each record
function sendNext(context) {
  // Repeat until the first execute() passes
  while(records.length != 0) {
    // get and remove first element
    var record = records.shift();
    // create request
    var req = new HttpClientRequest(endpoint);
    req.complete = onComplete; // assign complete callback
    var hasProxy = false;
    var async = true;
    var timeout = 2000;
    try {
      req.execute(hasProxy, async, timeout, context);
      successRequests.push(req); // store successful requests
      return; // exit sendNext function because will be called by onComplete
    } catch (error) {
      logWarning('Error:', error);
      failedRequests.push(req); // store failed requests
      continue; // continue because not called by onComplete
    }
  }
}

// Start 3 requests at the same time
sendNext({id:1}); // use any variable, such as an id, to debug
sendNext({id:2});
sendNext({id:3});

// Wait until all requests are completed
HttpClientRequest.wait(requests);
```

See [JSAPI execute](https://docs.campaign.adobe.com/doc/AC/en/jsapi/m-HttpClientRequest-execute.html) reference

See this [tutorial to install JS library]({% post_url 2018/2018-10-15-use-javascript-libraries-in-adobe-campaign %}) such as underscore or Moment JS in Adobe Campaign.
