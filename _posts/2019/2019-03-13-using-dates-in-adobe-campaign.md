---
title: Date Best Practices in Adobe Campaign
categories: [opensource,adobe campaign,date]
---

<p class="text-center">📊📧🌍</p>
<!--more-->

- Generic helpers
- xml2js
- js2sql
- sql2js
- sql

## JS Adobe Campaign helpers
```js
/**
 * @return Date of the database server
 */
getCurrentDate()
/**
 * @return Date of the linux server
 * @deprecated, use @see getCurrentDate()
 */
// new Date()
```

## MomentJS external library
```js
// load lib
loadLibrary('vendor:moment'); // @see https://myrosblog.com/2018/10/use-javascript-libraries-in-adobe-campaign/
vars.yesterday = moment().subtract(1, 'day').format('YYYY-MM-DD'); // yesterday July 1st 2020
var today = moment(); // today July 2nd 2020
vars.lastDayOfMonth = (today.clone().endOf('month')).format('YYYY-MM-DD HH:mm:ss'); // July 31st 2020
vars.lastDayOf12m   = (today.clone().endOf('month').subtract(1, 'year')).format('YYYY-MM-DD HH:mm:ss'); // July 31st 2019
vars.lastDayOf24m   = (today.clone().endOf('month').subtract(2, 'year')).format('YYYY-MM-DD HH:mm:ss'); // July 31st 2018
vars.thisMonday = moment().startOf('week');
vars.lastMonday = moment().subtract(7, 'days').startOf('week');
```
See [MomentJS docs](https://momentjs.com/docs/#/manipulating/)

## In Workflow activities (Configuration)
```console
/home/customers/acme/incoming/folder/<%= formatDate(getCurrentDate(), '%4Y%2M%2D-%2H%2N%2S') %>-file.txt
```
See next chapter for details

## js2string - Javascript Date to String
```js
/**
 * Converts a Javascript Date to a String
 * @return string
 */
formatDate(Date date, String format , String timeZone = null)
formatDate(getCurrentDate(), '%4Y%2M%2D-%2H%2N%2S'); // "20190430-150837" for folder names
formatDate(getCurrentDate(), '%A %D %B %4Y'); // "Tue 30 Apr 2019" for technical emails
formatDate(getCurrentDate(), '%Al %D %Bl %4Y'); // "Tuesday 30 April 2019" for marketing emails
```
From https://docs.campaign.adobe.com/doc/AC/en/jsapi/f-formatDate.html

*Note: Prefix numbers with a number (2, 4..) to add leading zeros.*

*Note: Prefix names with l to use full name instead of short name.*

| Code | Type | Example |
|-|-|-|
| %Y | Year | 2019 |
| %M | Month of the year (1-12) | 6 |
| %2M | Month of the year (01-12) | 06 |
| %B | Month name (short) | Jan |
| %Bl | Month name (full) | January |
| %D | Day of the month (1-31) | 3 |
| %A | Day name (short) | Mon |
| %Al | Day name (short) | Monday |
| %J | Day of the year (1-366) | |
| %W | Week of the year | |
| %H | Hour 24h (0-23) | 5 |
| %2H | Hour 24h (00-23) | 05 |
| %I | Hour 12h (1-12) | |
| %P | AM/PM | AM |
| %N | Minutes (0-59) | |
| %S | Seconds (0-59) | |

## xml2js - XML String date to Javascript Date
```js
var query = NLWS.xtkQueryDef.create({queryDef: {
  schema: "nms:recipient", operation: "get", 
  select: { node: {expr: "@lastModified"} }, 
  where: { condition: {expr: "@id=123456"} },
}});
var recipientXml = query.ExecuteQuery();
var lastModified = parseTimeStamp(recipientXml.$lastModified); // @return Date
```

## js2sql - Javascript Date to SQL String format
Using Format 

```js
loadLibrary("xtk:common.js"); // for Format
var recipient = NLWS.nmsRecipient.load(recipientId);
recipient.lastModified = Format.formatDateTimeInter(getCurrentDate());
recipient.save();
```

## sqlExec - Using standard `sqlExec` tool
Use `$(curdate)`
```js
sqlExec("UPDATE nmsDelivery SET tsLastModified=$(curdate) WHERE iId=$(l)", 1234);
```

## sql2js - SQL String to Javascript Date
```js
var recipient = NLWS.nmsRecipient.load(recipientId);
var lastModified = parseTimeStamp(recipient.lastModified); // @return Date
```

Accepted String formats for `parseTimeStamp`:
```console
2005-03-02 00:00:00
2005-03-02
2005-03-02T14:32:26
2005-03-02T14:32:26.0000
2005-03-02T14:32:26.0000000+01:00
2005-03-02T14:32:26+01:00
2005-03-02T14:32:26Z
2005-03-02T14:32:26.0005Z
2005/03/02 14:32:25
```

## SQL
Create a Year To Date (YTD) filter
```js
/* on or after */ ToDateTime('2019-01-01')
/* on or after */ ToDateTime(Year( GetDate())+'-01-01')
```
