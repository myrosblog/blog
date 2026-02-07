---
title: Tracking links detection & formula with targetData in Adobe Campaign (+ UTM codes!)
categories: [delivery,opensource,adobe campaign]
---
How to track your HTML links in an Adobe Campaign delivery when they are generated from upstream data `targetData`?
<p class="text-center">🔗🔎☁️</p>
<!--more-->

## Step 0: Prerequisites
- Campaign with a Query, an Enrichment with `customUrl` field and an Email delivery:
  - With a static link `<a href="https://blog...">`
  - With a targetData link `<a href="<%= targetData.customUrl %>">`
  - "Display URLs" checked

ACC only recognizes the static link:
![](/assets/images/2020/acc-tracking-links-prerequisites.jpg)

Let's fix it!

## Step 1/2: `href` must start with `https://`
- Prefix `<%= targetData` with `https://`
- Remove https:// (or http://) in the `targetData.link` with the regex `.replace(/^https?:\/\//, '')`
![](/assets/images/2020/acc-tracking-links-href-https.jpg)

## Step 2/2: Tracking formula for UTM codes
- The tracking link formula doesn't work with targetData:
![](/assets/images/2020/acc-tracking-links-formula-result.jpg)

- This is because by default the formula has a condition on `$(urlstring)`:
![](/assets/images/2020/acc-tracking-links-formula-code.jpg)

- And the formula is executed BEFORE targetData is replaced by its content!
- The condition regex must contain a `OR targetData` :
```javascript
<%@ include option='NmsTracking_ClickFormula' %>
<%
var pattern = /(blog\.myrosblog\.com|targetData)/i;
if( $(urlstring).match(pattern) ){
%>
&utm_source=newsletter&utm_medium=email&utm_campaign=<%= message.delivery.internalName %>
<% } %>
```
![](/assets/images/2020/acc-tracking-links-formula-fixed-code.jpg)

- Which results in a targetData link tracked with UTM via the delivery formula:
![](/assets/images/2020/acc-tracking-links-formula-fixed-result.jpg)
