---
title: Use NodeRed v2 for free on Heroku!
categories: [opensource,nodered,automation,heroku]
---

Deploy instantly and for free an instance of NodeRed v2 for daily use and various automations!

<p class="text-center">🟥🔛☁️</p>

<!--more-->

## Deploy on Heroku in 1 click

Use the following button to 1-click deploy an instance on heroku:

<a href="https://heroku.com/deploy?template=https://github.com/myrosblog/node-red-heroku" title="Deploy Node-Red to Heroku" target="_blank">
    <img src="https://www.herokucdn.com/deploy/button.png" style="max-height:150px" class="no-lightgallery"/>
</a>

Which will open the following screen:

![todo](/assets/images/2021/heroku-deploy-node-red.png)

Choose an `App Name`, use a strong password for the `NODE_RED_PASSWORD` value and hit `Deploy App`.

You can now freely access `https://your-app-name.herokuapp.com/red`:

![todo](/assets/images/2021/node-red-login-page-on-heroku.png)

When logged in, hit the Menu button to check the `2.0.5` version:

![todo](/assets/images/2021/node-red-version-about.png)

## Add new Nodes to the Palette

Node-Red modules may be added via the `Menu`>`Manage Palette` link from the (Node Library)[https://flows.nodered.org/search?type=node]:

![todo](/assets/images/2021/node-red-add-node-from-palette.png)

## Add Javascript libraries for the `Function` node

Example for the `lodash` library ([npm link](https://www.npmjs.com/package/lodash)).

- Fork the root project [Fork myrosblog/node-red-heroku](https://github.com/myrosblog/node-red-heroku/fork)
- Edit `package.json` by adding `lodash` to `dependencies`:
```js
"dependencies": {
    [...],
    "lodash": "~4.x"
}
```
- Deploy to heroku
- Once in Node-Red editor, open the function node>`Setup`>`Modules`
- `Module Name=lodash`and `Import as=_`
![todo](/assets/images/2021/node-red-import-npm-library.png)
- Use it in `On Message`:
```js
msg.payload = _.lowerCase(msg.payload);
```

Voilà !
