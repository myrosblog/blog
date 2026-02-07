---
title: Web cheatsheet & Tampermonkey
categories: [opensource,tampermonkey,web]
---

Web tools

<p class="text-center">🛜💻🔗</p>

<!--more-->

# Qwant Ad Shield

```js
// ==UserScript==
// @name         Qwant Ad Shield
// @namespace    http://tampermonkey.net/
// @version      1.1.0
// @description  xx
// @author       Myros
// @match        https://www.qwant.com/*
// @icon         https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Qwant_new_logo_2018.svg/250px-Qwant_new_logo_2018.svg.png
// @grant        GM_addStyle
// ==/UserScript==

(function() {
    'use strict';

    function hideAds() {
        console.log('QwantAdShield:hideAds');
        GM_addStyle(`
            /* Adjust the gap between elements */
            .result__ext > div {
                gap: var(--spacing-100) !important;
            }

            /* Hide ad elements */
            .result__ext,
            .result__ext > div > div {
                background: lightblue;
                height: 16px;
                display: block;
                overflow: hidden;
            }
        `);
    }

    hideAds();
})();
```
