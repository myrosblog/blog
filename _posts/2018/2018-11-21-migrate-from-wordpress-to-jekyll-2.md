---
title: Create a Search in Jekyll [Part 2/2]
layout: post
categories:
  - jekyll
  - opensource
  - server
---
This post is the part 2 of the tutorial collection on how to migrate from Wordpress to Jekyll.
- [Part 1. Introduction]({% post_url 2018/2018-11-21-migrate-from-wordpress-to-jekyll %})
- Part 2. Create the Search component

## Simple method: text search with SimpleJekyllSearch
This feature consists of creating a JSON object with all pages and posts with Jekyll `site.posts` in the file `/search.json`:
{% raw %}```js
---
---
[
  {% for post in site.posts %}
    {

      "title"    : "{{ post.title | escape }}",
      "url"      : "{{ site.baseurl }}{{ post.url }}",
      "categories" : "{{ post.categories | join: ', ' }}",
      "tags"     : "{{ post.tags | join: ', ' }}",
      "date"     : "{{ post.date }}"

    } {% unless forloop.last %},{% endunless %}
  {% endfor %}
]
```{% endraw %}
*See source [https://github.com/myrosblog/blog/blob/master/search.json](https://github.com/myrosblog/blog/blob/master/search.json)*

The file is immediately available at [/search.json](/search.json).

Now each time the site is built, a search.json is created, containing every post along with its title, url, categories and tags.

[Christian Fei](https://github.com/christian-fei/Simple-Jekyll-Search) developed a plugin to display the list of results, based on a simple text search:
```html
<input id="search-input" class="form-control mr-sm-2" type="search" placeholder="Search" aria-label="Search">
<ul id="results-container"></ul>
<script src="https://cdn.jsdelivr.net/npm/simple-jekyll-search@1.7.1/dest/simple-jekyll-search.min.js"></script>
<script>
SimpleJekyllSearch({
  searchInput: document.getElementById('search-input'),
  resultsContainer: document.getElementById('results-container'),
  json: '/search.json'
})
</script>
```

*Source [https://blog.webjeda.com/instant-jekyll-search](https://blog.webjeda.com/instant-jekyll-search)*

## Advanced search: Full-text search with lunr.js

Following the method above, we can take a great advantage of the Jekyll automatic index building and link it to a Full text search library such as lunr.js. This way, we can have more natural langugage processing, all for free!

The index is an object `documents` containing an entry per post, with its URL as the key.

`/search-lunr.js`
{% raw %}```js
---
---
var documents = {
  {% for post in site.posts %}
    "{{ site.baseurl }}{{ post.url }}": {
      "title"    : "{{ post.title | escape }}",
      "url"      : "{{ site.baseurl }}{{ post.url }}",
      "categories" : "{{ post.categories | join: ', ' }}",
      "tags"     : "{{ post.tags | join: ', ' }}",
      "date"     : "{{ post.date }}",
      "excerpt"     : "{{ post.excerpt | strip | strip_newlines | strip_html }}"
    } {% unless forloop.last %},{% endunless %}
  {% endfor %}
};

```{% endraw %}

[https://lunrjs.com/guides/getting_started.html](https://lunrjs.com/guides/getting_started.html)
```html
<script src="https://unpkg.com/lunr/lunr.js"></script>
<script>
  // create lunr index
  const idx = lunr(function () {
    this.ref('url'); // the url will be used as the lunr id
    this.field('category');
    this.field('title');
    this.field('excerpt');
    this.field('date');
    for(var doc in documents) {
      this.add(documents[doc]);
    }
  });
  // watch input
  var $searchInput;
  var $resultsContainer;
  $(function(){
    var $searchInput = $('#search-input');
    var $resultsContainer = $('#results-container');
    $searchInput.on('input', function() {
      $resultsContainer.empty();
      var val = $searchInput.val();
      if(val.length < 2) return;
      var results = idx.search(val);
      for (result of results) {
        var doc = documents[result.ref]; // get document via the lunr id
        $resultsContainer.append('<li><a href="'+doc.url+'">'+doc.title+'</a></li>');
      }
    });
  })
</script>
```

## Server-side search with Algolia
What's the point if all the above is working fine, right? Because Algolia is A) powerful and B) provides analytics on searches performed (Popular searches, no results, geographics requests).

### Create the index
With the Gem `gem 'jekyll-algolia'`, see [https://community.algolia.com/jekyll-algolia/getting-started.html](https://community.algolia.com/jekyll-algolia/getting-started.html)

### Add html to perform the search
```html
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/instantsearch.js@2.10.4/dist/instantsearch.min.css">
  <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/instantsearch.js@2.6.0/dist/instantsearch-theme-algolia.min.css">
<script defer src="https://cdn.jsdelivr.net/npm/moment@2.22.2/moment.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/instantsearch.js@2.10.4"></script>
<script defer src="{{site_url}}/assets/js/search-algolia.js" charset="utf-8"></script>
<script>
  const search = instantsearch({
    appId: 'appId',
    apiKey: 'apiKey',
    indexName: 'jekyll',
    routing: true
  });

  // initialize SearchBox
  search.addWidget(
    instantsearch.widgets.searchBox({
      container: '#search-input',
      placeholder: 'Search'
    })
  );

  // initialize hits widget
  search.addWidget(
    instantsearch.widgets.hits({
      container: '#results-container',
      templates: {
        empty: 'No results',
        item: function(hit) {
          var date = moment.unix(hit.date).format('MMM D, YYYY');
          return `
            <div class="post-item">
              <span class="post-meta">${date}</span>
              <h2><a class="post-link" href="{{ site.baseurl }}${hit.url}">${hit._highlightResult.title.value}</a></h2>
              <div class="post-snippet">${hit._highlightResult.html.value}</div>
            </div>
          `;
        }
      }
    })
  );

  search.start();
</script>
```
