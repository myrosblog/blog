---
title: Report of deliveries filterable by date in Adobe Campaign
categories: [opensource, adobe campaign, report]
---

Let's create a nice Report for the business teams to be able to analyze their deliveries with the Label, the Subject, the UTM Codes, the delivery indicators (sent/received/failed) and the tracking indicators (open/click/transactions).

<!-- more -->

## Objective

We will be achieving the following:

![](/assets/images/2018/07/Preview-of-Deliveries-by-date-Report.jpg)

## Workflow setup

Create a Report Workflow like below:

![](/assets/images/2018/07/Deliveries-by-date-Workflow.jpg)

Also, create 2 workflow variables in `Workflow Properties > Variables`
- `startDate` (Datetime)
- `endDate` (Datetime)

![](/assets/images/2018/07/adobe-campaign-report-newsletter-workflow-variables.jpg)

## The JS activity
We are going to rely on 2 the context vars we just created, with `ctx.vars`:

```js
loadLibrary('vendor:moment')
// set default date
ctx.vars.startDate = moment().startOf('month').format('YYYY-MM-DD');
ctx.vars.endDate = moment().endOf('month').format('YYYY-MM-DD');
```

See this [tutorial to install the library]({% post_url 2018/2018-10-15-use-javascript-libraries-in-adobe-campaign %}) `vendor:moment` can be installed 

## The Query

In the query, remove proofs via `@FCP = No`, ensure you have a `contact date is not empty` and Contact date should be:
- `on or after`  `ToDate($([vars/startDate]))`  if `length($([vars/startDate]) ) > 0`  AND
- `on or before` `ToDate($([vars/endDate]))`    if `length($([vars/endDate]) ) > 0`

![](/assets/images/2018/07/Query-filter-for-deliveries.jpg)

Also, order by Contact Date `ASC`.

## The Page

Create a container with 2 inputs Date and a Link Refresh:

![](/assets/images/2018/07/adobe-campaign-report-newsletter-start-date.jpg)

![](/assets/images/2018/07/adobe-campaign-report-newsletter-refresh.jpg)

Then, the table should look as follow:

![](/assets/images/2018/07/adobe-campaign-report-newsletter-table.jpg)

## Fix timezone

Add a new JS activity before the Query:

```js
loadLibrary('vendor:moment')
// set default start/end date to first/last day of today's month
// we have to set 10AM to be sure for the timezone
ctx.vars.startDate = moment(ctx.vars.startDate.toString()).hour(10).format('YYYY-MM-DD HH:mm:ss');
ctx.vars.endDate = moment(ctx.vars.endDate.toString()).hour(10).format('YYYY-MM-DD HH:mm:ss');
```
