---
title: Sub-workflow activity in Adobe Campaign
categories: [adobe campaign, automation, javascript, neolane, opensource]
---

Your workflows contain too many activities? You're lost between your jumps, transitions and end activities? Consider using a sub-workflow with the tutorial below. This way, you can have workflows as tiny as possible, they're are way easier to maintain!

<!--more-->

## Objective

This Master workflow (with some init variables)

![](/assets/images/2018/07/Sub-workflow-Master.jpg)

is going to call the child workflow (which will edit these variables)

![](/assets/images/2018/07/Sub-workflow-Child.jpg)

We will also discuss [Pros & Cons](#pros--cons) of this approach, and what we can do to [go further](#going-further) with for example a File Collector/File Transfer.

## Setup the Master workflow

![](/assets/images/2018/07/Sub-workflow-Master-step-1.jpg)

Where `set x=1` contains:
```js
instance.vars.x = 1
```

And `print x` has the following JavaScript code:
```js
logInfo('x: '+instance.vars.x)
```

## reate the Child sub-workflow

![](/assets/images/2018/07/Sub-workflow-Child.jpg)

There are 2 important things here, the 2 Jumps:

- The Arrival Jump (on the left) has a priority of 1. If you have multiple Arrival Jumps, Adobe Campaign will use the Arrival Jump with the lowest number.
- The Starting Jump (on the right) has a priority of 2. If you have multiple Starting Jumps, Adobe Campaign will use the Starting Jump with the highest number.

For the sub-workflow to work correctly, you have to have **only ONE Arrival Jump with the lowest number**, and **only ONE Starting Jump with the highest number**.

For example, if you have Starting Jumps 1, 50 and 100, you should have only ONE Starting Jump with a priority of 100!

See [https://docs.campaign.adobe.com/doc/AC/en/WKF\_Repository\_of\_activities\_Order_activities.html#Sub-workflow](https://docs.campaign.adobe.com/doc/AC/en/WKF_Repository_of_activities_Order_activities.html#Sub-workflow) for reference

Then, the test Activity is really standard, made just for the example here:

![](/assets/images/2018/07/Sub-workflow-Child-test-activity.jpg)

## Complete the Master Activity

Open the Sub-workflow Activity, and Select the Child Sub-workflow, it will automatically create an outbound transition with the label of the Starting Jump in the Child Sub-Workflow.

![](/assets/images/2018/07/Sub-workflow-Master-Link-to-Child.gif)

Finish the workflow by adding what you need. Here, we're just gonna print the value of `x`:

![](/assets/images/2018/07/Sub-workflow-Master-final-step.jpg)

## Run and Enjoy!

Go ahead and run the Master workflow. You can see the transition arrows getting blue until they hit the End Activity. Well done! Go back to the Child sub-workflow, and refresh it.

What?? It stays in `Being Edited` mode, no transition has been executed and the logs are empty. What is going on?

Refresh your folder, and you can see that Adobe Campaign created a third workflow, with the Child WF being a `template`.

Ok. But what happened? `x`  has a value of `1`, so in the Child workflow, its value will be updated to `99`. Here's the log:

![](/assets/images/2018/07/Sub-workflow-Master-logs.jpg)

But *look closely*, a couple of things happens:

  * Child logs are empty: ![](/assets/images/2018/07/Sub-workflow-Child-empty-logs.jpg)
  * Child logs are in the Master logs, labelled by `subworkflow`
  * The Child has modified `x` to `99`, and sent it back to the Master, but the modification is not persisted. `x` is still equal to `1`: ![](/assets/images/2018/07/Sub-workflow-Master-logs-1.jpg)
  * Child sub-workflow is still in `Being Edited` status, and its transition arrows are untouched: ![](/assets/images/2018/07/Sub-workflow-Child-still-in-Being-Edited-status.jpg)
  This means you cannot `Right click > Display the target`. Which is a real pain in case of debugging! This is a major disadvantage of this method (see below for [Pros & Cons](#pros--cons))

## Pros & Cons

✅ Pros:
- Improve readability and maintainability
- Executed synchronously, so you can wait until the sub-workflow is done

❌ Cons:
- Unable to Display the target
- Unable to see the count of intermediate populations
- Logs are aggregated in the Master workflow
- Child logs are labelled "sub-workflow" so we don't know the activity it's been called from

## Going further

A typical application of this method would be to have a File Collector in the Master, and for each file, call the Child Workflow. Let's do it and check if there's any flaw in the process!

Use this Master:
![](/assets/images/2018/07/File-Collector-test-Master.jpg)

This child
![](/assets/images/2018/07/File-Collector-test-Child.jpg)

And for example those 3 CSV files:
![](/assets/images/2018/07/File-Collector-test-FTP-listing.jpg)

Start the master, and here's what happens:

![](/assets/images/2018/07/File-Collector-test-Master-logs-annotated.jpg)


- The Child is executed 3 times as we have 3 files in the folder
- The Master waits for all Children to be processed before resuming
- `vars.filename`  is shared between workflows
- Adobe Campaign created 3 copies of the Child sub-workflow: ![](/assets/images/2018/07/File-Collector-test-3-copies.jpg)
- But they all have empty logs ![](/assets/images/2018/07/File-Collector-test-1-copy-with-empty-log.jpg)

As an alternative method, you can directly call another workflow with this JavaScript code:
```js
NLWS.xtkWorkflow.PostEvent("myWorkflowInternalName", "signalActivityName", "", <variables var1={vars.var2}/>, false);
```

Find more details about this on [the tutorial to call another workflow in Adobe Campaign]({% post_url 2018/2018-07-24-call-another-workflow-in-adobe-campaign %}).
