---
layout: post
title: Blogging with Knitr and Jekyll
categories: ["post"]
tags: ["knitr", "jekyll", "markdown", "rmarkdown"]
---

<p class="update">
    <strong>Update:</strong> I no longer do this because <a href="https://github.com/rstudio/blogdown">Blogdown</a> is a much nicer solution. You probably want to use that instead, but I'm leaving this up for historical purposes.
</p>

I wanted to be able to share [R](http://r-project.org) code for various
tasks in a blog-like format. [Jekyll](http://jekyllrb.com) is a popular
blogging tool based upon the idea of using
[Markdown](http://daringfireball.net/projects/markdown/) to write and
Jekyll to publish the content as
[HTML](http://en.wikipedia.org/wiki/HTML).

This was intriguing to me but I didn’t want to just write in Markdown, I
wanted to post R code as well. A fantastic solution for merging the two
is [knitr](http://yihui.name/knitr), which allows the author to
alternate between prose and R code seamlessly, including the result of
the R code in-line. Knitr uses the .RMarkdown extension which get
converted to Markdown (.md) files when they are knit using the `knit`
function.

Jekyll doesn’t have an easy way to let you write posts in RMarkdown
directly but I found a simple solution from Jason C. Fisher [on his
blog](http://jfisher-usgs.github.io/r/2012/07/03/knitr-jekyll/). He
outlines a method for knitting his RMarkdown files manually and copying
the resulting Markdown and images into the directory containing his
Jekyll site.

This approach would’ve worked fine but I really wanted to write my
RMarkdown posts inside the directory containing my Jekyll blog. Ideally,
I would be able to write my RMarkdown right next to my Markdown and let
Jekyll do the rest.

I toyed around with the idea of using Jekyll’s generators (See section
‘Generators’ [here](http://jekyllrb.com/docs/plugins/)). Generators are
useful for converting content from one form to another (e.g. .md to
.html). A generator for knitting RMarkdown files into HTML would be
trivial to write (In fact I did write one) but it would not be
straightforward to handle RMarkdown posts with images in them. Instead
of tweaking a Jekyll generator to handle images, I opted to just write
an R script that is run prior to Jekyll’s `build` command.

To do this, I had to create a folder called `\_rmd` next to the standard
`\_posts` folder for the .Rmd files to live:

    ├── _posts
    │   ├── 2014-01-01-example-post.md
    ├── _rmd
    │   └── 2014-01-01-example-post.Rmd
    └── images
        └── 2014-02-10-example-post
            └── example-image.png

The R script detects any files in the `_rmd`\_ folder needing to be knit
and knits them. The resulting Markdown file is placed in the `\_posts`
folder.

By default, any .Rmd files without a corresponding .md file need to be
knit. This can be overridden by passing the script the –all flag which
knits all files from scratch. Each file is knit and its images are
output into a subfolder of the images folder with the same name as the
post using knitr’s built in [options](yihui.name/knitr/options). Placing
images for each post in a subfolder is purely my preference though it
does help organize the images better and removes the need to keep unique
figure names in my posts.

Here is the full source of `knit-all.r`

{% gist amoeba/9073217 %}

The corresponding Rakefile sets up the basic commands for working on the
site:

{% gist amoeba/9073226 %}

The writing process then looks like this:

1.  Write a post in the `\_rmd` folder
2.  Run `rake knit`
3.  Run `rake build`
4.  Run `rake serve` to preview the post
5.  (Optional) Commit and `git push` to publish

Please let me know if you have any thoughts or suggestions on how this
can be done more simply.
