---
layout: front
title: brycemecum.com
---

Hi, I'm Bryce and this is my home on the web.

I'm currently working at [Columnar](https://columnar.tech) on [Apache Arrow](https://arrow.apache.org), mostly on [ADBC](https://arrow.apache.org/adbc), and am a member of the Apache Arrow PMC. I was previously at [Voltron Data](https://voltrondata.com) supporting enterprises on Arrow and more.

Before my time in the private sector, I was at [NCEAS](https://www.nceas.ucsb.edu/) making [software](https://github.com/nceas).

In my free time, I work on [TreeStats](https://treestats.net) and other stuff related to [Asheron's Call](https://en.wikipedia.org/wiki/Asheron%27s_Call). I worked in wildlife and fisheries prior to software and [still do](https://aoos.org/project/yukon-river-chinook-run-timing/).

## Posts

<ul class="post-list">
{% for post in site.posts limit:3 %}
  <li>
    <a href="{{ post.url }}">{{ post.title }}</a>
    <span class="post-date">{{ post.date | date: "%Y-%m-%d" }}</span>
  </li>
{% endfor %}
</ul>

[All posts →](/posts)

## Projects

<ul class="project-list">
{% assign visible_projects = site.projects | where_exp: "p", "p.listing != true" | sort: "year" | reverse %}
{% for project in visible_projects %}
  <li>
    <div class="project-header">
      <a href="{{ project.link }}">{{ project.name }}</a>
      {% if project.year %}<span class="project-year">{{ project.year }}</span>{% endif %}
      {% if project.tags %}{% for tag in project.tags %}<span class="tag">{{ tag }}</span>{% endfor %}{% endif %}
    </div>
    <div class="project-description">{{ project.description }}</div>
  </li>
{% endfor %}
</ul>
