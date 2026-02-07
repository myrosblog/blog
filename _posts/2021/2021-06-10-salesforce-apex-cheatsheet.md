---
title: Salesforce Service APEX Cheatsheet
categories: [salesforce,apex]
---
Excerpt here...
<p class="text-center">🐍👑🌍</p>
<!--more-->

## SOQL, Loops, dates, exception

```java
// soql
List<Account> accounts = [SELECT Id, Name FROM Account];
System.debug('size: '+accounts.size());
for(Account account : accounts){
  throw new IllegalArgumentException('Test'); // Exception class is abstract. Use Exceptions.SystemException, ApplicationException
}
Account a = new Account(Name='');
insert a;
a.Name = 'New name';
update a;
// date
datetime nowDatetime = datetime.now(); // for saleItemGeneratedId PLOCRM-21
string nowDate = nowDatetime.format('yyyyMMdd');
string nowTime = nowDatetime.format('HHmmss');
```

## Apex Trigger

```java
trigger FcoCaseTrigger on Case (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    if(Trigger.Isupdate){
        FcoCaseHelper.process(Trigger.new);
    }
}

@isTest
public with sharing class FcoCaseTriggerTest {
    @isTest private static void test() {
    	Case c = new Case(Name='TestCase');
	insert c;
	List<Case> createdCases = [Select Id from Case where Name != ''];
        System.assertEquals(true, createdCases.size() >= size);
    }
}
```

## HTTP GET Request

Make sure to whitelist the external URL in Setup>Security>`Remote Site Settings`.

```java
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint('https://jsonplaceholder.typicode.com/users');
request.setMethod('GET');
HttpResponse response = http.send(request);
List<Object> records = (List<Object>) JSON.deserializeUntyped(response.getBody());
for (Object record: records) {
  Map<String, Object> mapped = (Map<String, Object>)record;
  String sku = (String)mapped.get('id');
}

@isTest
global class FcoCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"id": 1}]');
        response.setStatusCode(200);
        return response; 
    }
}
```

## HTTP POST Request to SOAP API

Ex: Adobe Campaign Recipients broadlogs update

```java
Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint('https://xxx.neolane.net/nl/jsp/soaprouter.jsp');
request.setMethod('POST');
request.setHeader('Content-Type', 'application/xml');
request.setHeader('SOAPAction', 'xtk:persist#WriteCollection');
String body = 
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:xtk:session">'+
   '<soapenv:Header/>'+
   '<soapenv:Body>'+
      '<urn:WriteCollection>'+
         '<urn:sessiontoken>user_name/pass_word</urn:sessiontoken>'+
         '<urn:domDoc>'+
            '<broadLogRcp-collection xtkschema="nms:broadLogRcp">'+
              '<broadLogRcp id="129106000" status="5" _operation="update" _key="@id" eventDate="2018-12-25 11:05:59"/>'+
              '<broadLogRcp id="129117000" status="4" _operation="update" _key="@id" eventDate="2018-12-25 11:05:59"/>'+
            '</broadLogRcp-collection>'+
         '</urn:domDoc>'+
      '</urn:WriteCollection>'+
   '</soapenv:Body>'+
'</soapenv:Envelope>';
request.setBody(body);
HttpResponse response = http.send(request);
System.debug(response.getBody());
```

## HTTP POST Request to Marketing Cloud REST API
```java
Http http = new Http();
// auth
HttpRequest request = new HttpRequest();
request.setEndpoint('https://xxx.auth.marketingcloudapis.com/v2/token');
request.setMethod('POST');
request.setHeader('Content-Type', 'application/json');
String body = '{"grant_type": "client_credentials","client_id": "xxx","client_secret": "xxx","scope": "email_read email_write email_send","account_id": "xxx"}';
request.setBody(body);
HttpResponse response = http.send(request);
System.debug(response.getBody());
Object record = (Object) JSON.deserializeUntyped(response.getBody());
Map<String, Object> mapped = (Map<String, Object>)record;
String access_token = (String)mapped.get('access_token');
System.debug(access_token);
// call
request = new HttpRequest();
request.setEndpoint('https://xxx.rest.marketingcloudapis.com/messaging/v1/email/messages/');
request.setMethod('POST');
request.setHeader('Authorization', 'Bearer '+access_token);
request.setHeader('Content-Type', 'application/json');
body = '{  "definitionKey": "Auto_WW_DoubleOptinQRCode",  "recipients": [{      "contactKey": "0034H00002ZiYo5QAF",      "to": "myrosblog20220818b@yopmail.com",      "attributes": {        "FirstName": "John",        "LastName": "Doe"      }  }]}';
request.setBody(body);
response = http.send(request);
System.debug(response.getBody());
```

See [Marketing Cloud REST API]({% post_url 2022/2022-08-18-salesforce-marketing-cloud-rest-api %}).

## Schedule Apex Job

Find jobs in Setup>Environments>Jobs>`Scheduled Jobs`.

```java
global class FcoSchedule implements Schedulable {
	global void execute(SchedulableContext ctx) {
        // process
    }
}

// Then in anonymous window:
FcoSchedule x = new FcoSchedule();
// Seconds Minutes Hours Day_of_month Month Day_of_week Year
String CRON_EXP = '0 0 1 * * ? *'; // https://www.freeformatter.com/cron-expression-generator-quartz.html
String jobId = System.schedule('JobName', CRON_EXP, x);
System.debug(jobId);
```

Stop job from `Scheduled Jobs`>Delete or:
```java
System.abortJob(jobId);
```

## Parent-child SOQL request (and datetime)
```java
Datetime dtFrom = DateTime.newInstance(2021,09,01,00,0,0);
List<Sale__c> sales = [
    SELECT 
	Id, Name, Locale__c,
	(
	    SELECT Id, Quantity__c, Product__c, Amount__c 
	    FROM Ticket_Lines__r 
	    WHERE Quantity__c>0 AND Amount__c>0
	)
    FROM Sale__c 
    WHERE Purchase_Date__c > :dtTo
];
for(Sale__c sale: sales){
    System.debug(sale.Ticket_Lines__r.size()+' lines');
}
```

## Delete Apex from Production instance

Create ZIP with below files and then deploy via https://workbench.developerforce.com/ `Migration`>`Deploy`:

- `package.xml`

```xml
<!--?xml version="1.0" encoding="UTF-8"?-->
<package xmlns="http://soap.sforce.com/2006/04/metadata">
     <version>30.0</version>
</package>
```


- `destructiveChanges.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
     <types>
          <members>Class1</members>
	  <members>Class2</members>
	  <members>Class3</members>
          <name>ApexClass</name>
     </types>
<version>30.0</version>
</Package>
```

Source https://www.salesforceben.com/way-to-delete-apex-classes-from-production/
