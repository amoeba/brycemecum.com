---
layout: link
title: Reflecting on Apache Arrow in 2022
tags: ["apache-arrow"]
---

In [Reflecting on Apache Arrow in 2022](https://www.datawill.io/posts/apache-arrow-2022-reflection/), [Will Jones](https://www.datawill.io) does a really nice job providing a history of the [Apache Arrow](https://arrow.apache.org) project and the broader ecosystem it was originally created to help foster.
It's worth a read in full.

In his post, he describes the C++ Arrow ecosystem as being somewhat fractured and suggests this may be primarily out of the need for other teams to move fast but points out it may have something to do with libarrow's attractiveness as a dependency.

One quote jumped out at me as particularly insightful is this one:

> Yet those are all the same challenges our users experience; would it not be better if we felt those pains ourselves and had incentive to address them? I tend to think we would design better public APIs if we had to use them ourselves for our own query engine. [#](https://www.datawill.io/posts/apache-arrow-2022-reflection/#who-is-libarrows-and-aceros-audience:~:text=Yet%20those%20are%20all%20the%20same%20challenges%20our%20users%20experience%3B%20would%20it%20not%20be%20better%20if%20we%20felt%20those%20pains%20ourselves%20and%20had%20incentive%20to%20address%20them%3F%20I%20tend%20to%20think%20we%20would%20design%20better%20public%20APIs%20if%20we%20had%20to%20use%20them%20ourselves%20for%20our%20own%20query%20engine.)

This immediately reminded me of something I think [Jenny Bryan](https://jennybryan.org/) said (which I cannot currently find) about doing the hard things often so they aren't hard anymore.
If integrating parts of the Arrow ecosystem with each is hard for members of the Arrow project, it's likely to be considerably harder for those outside of it and I look forward to watching work on this front progress in 2023.
