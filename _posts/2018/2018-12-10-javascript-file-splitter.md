---
title: Javascript File Splitter
layout: post
categories:
  - javascript
  - opensource
  - adobe campaign
---
Javascript File Splitter compatible with Adobe Campaign 7.
<!--more-->
## Business case

You receive XML files that contain too many lines, you need to split them in multiple smaller files.

Orginal file:
```xml
<header>
  <row></row>
  <row></row>
  <row></row>
  <row></row>
  <row></row>
</footer>
```
Will be split into 3 files with `occurence="<row>"` and `maxOccurencesPerFile=2`:
```xml
<!-- file_0001.xml -->
<header>
  <row></row> <!-- occurence 1 -->
  <row></row> <!-- occurence 2 -->
</footer>
<!-- file_0002.xml -->
<header>
  <row></row> <!-- occurence 3 -->
  <row></row> <!-- occurence 4 -->
</footer>
<!-- file_0003.xml -->
<header>
  <row></row> <!-- occurence 5 -->
</footer>
```

## Usage
```js
loadLibrary('nms:fileSplitter');

var options = {
  filename: vars.filename,
  outputDir: vars.dir,
  header: '<?xml version="1.0" encoding="UTF-8"?>\n<orders xmlns="http://www.demandware.com/xml/impex/customer/2006-10-31">',
  occurence: '<order order-no',
  footer: '</orders>',
  ommitFirstHeader: true,
  maxOccurencesPerFile: 50,
  getNewFile: function(originalFile, nbOfFilesDone, options){
    var actualFile = options.outputDir+'/'+originalFile.name.replace('.xml.txt', '')+"_"+nbOfFilesDone.toString().padStart(4, "0")+'.xml';
    var f = new File(actualFile);
    f.open("a");
    logInfo('Created file '+f.fullName);
    return f;
  }
};
splitFile(options);
```
## Source code

`nms:fileSplitter`

```js
/**
 * Splits a file such as:
 * A
 * A
 * A
 * into:
 * File 1:
 * header
 * A
 * A
 * footer
 * File 2:
 * header
 * A
 * footer
 * 
 * with params occurence="A", times=2
 */
loadLibrary('vendor:underscore'); // see https://myrosblog.com/2018/10/use-javascript-libraries-in-adobe-campaign/

const TAG = 'nms:fileSplitter | ';

function splitFile(options){
  var defaultOptions = {
    filename: null,
    outputDir: null,
    header: null,
    occurence: null,
    footer: null,
    getNewFile: null,
    
    ommitFirstHeader: true,    
    maxOccurencesPerFile: 10,
  };
  options = _.defaults(options, defaultOptions);
  if(!options.filename || !options.outputDir || ! options.header || !options.occurence || !options.footer || !options.getNewFile){
    return logError(TAG+'splitFile error, missing filename, outputDir, header, occurence, footer or getNewFile in options');
  }
  logInfo(TAG+'splitFile with options:');
  logInfo(TAG+JSON.stringify(options));

  var originalFile = new File(options.filename);
  
  logInfo(TAG+'loading: '+options.filename)
  var text = loadFile(options.filename);
  logInfo(TAG+'splitting by newline')
  var lines = text.split('\n');
  logInfo(TAG+'ready to split into files');
  
  var textToWrite = '';
  if(!options.ommitFirstHeader){
    textToWrite = options.header;
  }
  var nbOfFilesDone = 1;
  var actualTime = 0;

  var f = options.getNewFile(originalFile, nbOfFilesDone, options);
  
  for(var i in lines){
    var line = lines[i];
    // if we find an occurence
    if(line.indexOf(options.occurence) > -1){
      // write
      f.writeln(textToWrite)
      textToWrite = '';
      // if it's time to create a new file
      if(actualTime >= options.maxOccurencesPerFile){
        logInfo(TAG+'New file for occurence at line '+i+' for occurence('+actualTime+'/'+options.maxOccurencesPerFile+') for line ('+i+')')
        // write footer and close file
        f.writeln(options.footer)
        f.close();
        // reset vars
        actualTime = 0;
        nbOfFilesDone++;
        // open the next file
        f = options.getNewFile(originalFile, nbOfFilesDone, options);
        /// adding header
        if(nbOfFilesDone>1 || !options.ommitFirstHeader){
          f.writeln(options.header)
        }
      }
      actualTime++;
    }
    
    if(i > 0 && line.length>1){
      textToWrite += '\n';
    }
    textToWrite += line;
  }
  // last one
  f.writeln(textToWrite);
  f.close();
  
  logInfo(TAG+'finished');
  return;
}
```

NB: to include underscoreJS library, see [https://myrosblog.com/2018/10/use-javascript-libraries-in-adobe-campaign/](https://myrosblog.com/2018/10/use-javascript-libraries-in-adobe-campaign/)

## Polyfills for `padStart()` in Adobe Campaign
Note: to make it work with Adobe Campaign, add the following polyfills for `padStart()` in `nms:polyfill`:
```js
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/repeat
if (!String.prototype.repeat) {
  String.prototype.repeat = function(count) {
    'use strict';
    if (this == null) {
      throw new TypeError('can\'t convert ' + this + ' to object');
    }
    var str = '' + this;
    count = +count;
    if (count != count) {
      count = 0;
    }
    if (count < 0) {
      throw new RangeError('repeat count must be non-negative');
    }
    if (count == Infinity) {
      throw new RangeError('repeat count must be less than infinity');
    }
    count = Math.floor(count);
    if (str.length == 0 || count == 0) {
      return '';
    }
    // Ensuring count is a 31-bit integer allows us to heavily optimize the
    // main part. But anyway, most current (August 2014) browsers can't handle
    // strings 1 << 28 chars or longer, so:
    if (str.length * count >= 1 << 28) {
      throw new RangeError('repeat count must not overflow maximum string size');
    }
    var rpt = '';
    for (var i = 0; i < count; i++) {
      rpt += str;
    }
    return rpt;
  }
}
// https://github.com/uxitten/polyfill/blob/master/string.polyfill.js
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/padStart
if (!String.prototype.padStart) {
    String.prototype.padStart = function padStart(targetLength,padString) {
        targetLength = targetLength>>0; //truncate if number or convert non-number to 0;
        padString = String((typeof padString !== 'undefined' ? padString : ' '));
        if (this.length > targetLength) {
            return String(this);
        }
        else {
            targetLength = targetLength-this.length;
            if (targetLength > padString.length) {
                padString += padString.repeat(targetLength/padString.length); //append to original to ensure we are longer than needed
            }
            return padString.slice(0,targetLength) + String(this);
        }
    };
}
```

Then add `loadLibrary('nms:polyfill');` in your main file.

