---
layout: link
tags: ["software", "react", "javascript", "web"]
---

From [Second-guessing the modern web](https://macwright.org/2020/05/10/spa-fatigue.html) by [Tom MacWright](https://macwright.org):

> But the cultural tides are strong. Building a company on Django in 2020 seems like the equivalent of driving a PT Cruiser and blasting Faith Hill’s “Breathe” on a CD while your friends are listening to The Weeknd in their Teslas. Swimming against this current isn’t easy, and not in a trendy contrarian way.

The four problematic areas Tom mentions, (bundle splitting, SSR, APIs, and data fetching) come out of his experience building really awesome things (e.g., at [Mapbox](https://www.mapbox.com) and [Observable](https://observablehq.com)) so he knows at least a bit about this. To build a "modern" JS application, I find myself having to write considerably more code and configure a multitude of additional libraries to get what I feel I used to get for free with, say, Ruby. And then I've still got problems I can't find good solutions for.

(Related are [DHH](http://web.archive.org/web/20200511105458/https://twitter.com/dhh)
's [thoughts](https://railsconf.com/2020/video/david-heinemeier-hansson-keynote-interview-with-david-heinemeier-hansson) about building for the web he delivered at RailsConf last week.)

Again from Tom's article, this gem is kind of hidden near the end:

> And it’s beneficial for companies to shift computing requirements from their servers to their customers browsers: it’s a real win for reducing their spend on infrastructure.
