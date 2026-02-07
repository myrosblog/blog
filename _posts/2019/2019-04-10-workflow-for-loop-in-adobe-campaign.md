---
title: '"for" loop as a worklow in Adobe Campaign'
categories: [opensource,adobe campaign]
---

You need to execute the same workflow multiple times with just 1 changing parameters? You need to go through a list of values and process them step by step?
Then you can simulate a classic "for" loop with the `Javascript` and the `Test` activities.

<p class="text-center">🐍👑🌍</p>
<!--more-->

## V1 with Advanced Javascript Code
![todo](/assets/images/2020/adobe-campaign-for-loop-workflow-v1.jpg)

Init
```js
instance.vars.counter = 0;
```

Advanced
```js
var countries = ["UK", "EU", "IT", "NL"];
if (instance.vars.counter >= countries.length) {
  task.postEvent(task.transitionByName('end'));
  return 0;
}
instance.vars.pays = countries[instance.vars.counter];
instance.vars.counter++;
task.postEvent(task.transitionByName('next'));
```

## V2 with Test
![todo](/assets/images/2019/04/adobe-campaign-for-loop-workflow.jpg)

Create a first `Javascript` code with the array init and the serialization with `JSON.stringify()`:
```js
var javascriptArray = [
  'France', 'Spain', 'UK',
];

vars.index = 0; // equivalent to "for(i=0"
vars.indexMax = javascriptArray.length; // compute the max index
vars.array = JSON.stringify(javascriptArray); // serialize the array as a string, per Adobe Campaign "vars" constraints
```

### Test activity
The `Test` activity is then setup as follow (equivalent):
```console
  - Label: End of loop?
  - Conditions
    - Label Yes: vars.index >= vars.indexMax
  - Default branching
    - Use Default connection: No
```

### Process
In the loop, you can use the array anytime with `JSON.parse()`:
```js
var current = JSON.parse(vars.array)[vars.index];
logInfo('Current index: '+vars.index+', current value: '+current);
```

### End of loop
At the end of the loop, a simple `vars.index++;` gets the job done!

## Run

```console
Workflow 'WKF999' is being run
Workflow restarted (operator 'Myros')
js3	Current index: 0, current value: France
js3	Current index: 1, current value: Spain
js3	Current index: 2, current value: UK
Workflow finished
```

![todo](/assets/images/2019/04/adobe-campaign-for-loop-logs.jpg)
