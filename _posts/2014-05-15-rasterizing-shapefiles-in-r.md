---
layout: post
title: Rasterizing Shapefiles in R
source: rmd
---


{% highlight r %}
print("Got here!")
{% endhighlight %}



{% highlight text %}
## [1] "Got here!"
{% endhighlight %}
I recently needed to convert a [shapefile](http://en.wikipedia.org/wiki/Shapefile) to a [raster](http://en.wikipedia.org/wiki/Raster_graphics) for use in another package and wanted to share my steps here.

For this demonstration, I started with the [Natural Earth Data](http://www.naturalearthdata.com) [1:10m Physical Vectors Land](http://www.naturalearthdata.com/downloads/10m-physical-vectors/) shapefile and will convert it to a raster using the `raster` package.

A bit of searching around on the web led me to [Amy Whitehead's](http://amywhiteheadresearch.wordpress.com/) page on [Converting shapefiles to rasters in R](http://amywhiteheadresearch.wordpress.com/2014/05/01/shp2raster/). The code listed there wasn't quite what I needed but gave me the head start on figuring out what I needed to do.

## Load required packages

The `maptools` package is used to import the shapefile to a `SpatialPolygonsDataFrame` and the `raster` package is for rasterizing the shapefile.


{% highlight r %}
library(maptools)
{% endhighlight %}



{% highlight text %}
## Loading required package: sp
## Checking rgeos availability: TRUE
{% endhighlight %}



{% highlight r %}
library(raster)
{% endhighlight %}



{% highlight text %}
## Loading required package: methods
{% endhighlight %}

## Load the shapefile we'll be rasterizing

Use the `readShapePoly` function from package `maptools` to read our shapefile in as a `SpatialPolygonsDataFrame`.

{% highlight r %}
# Retrieved from http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/ne_110m_land.zip
land <- readShapePoly("~/Documents/Datasets/ne_110m_land/ne_110m_land.shp")
{% endhighlight %}

## Create a blank raster

Before we can rasterize the shapefile, we need to create a blank raster. We specifiy the number of rows and columns to control the spatial resolution of our raster. We also have to specify the spatial extent, which will determine how much of the area of our shapefile we're rasterizing. Here, I use the `extent` function from the `raster` package to grab the extent of the shapefile and pass that to the `raster` function. You can also specify extent manually.


{% highlight r %}
blank_raster <- raster(nrow = 100, ncol = 100, extent(land))
{% endhighlight %}

If we were to plot this now, we would get an error because, by default, new rasters are created without any values. Rasters are fundamentally just like a 2-dimensional matrix (though they are stored as 1-d vectors). To get at this 2-d matrix, rasters have a [slot](http://stat.ethz.ch/R-manual/R-devel/library/methods/html/slot.html) called `data`, which you can access by calling `blank_raster@data`. You can get (and set) the values of the raster using the `values` function.


{% highlight r %}
values(blank_raster) <- 1
plot(blank_raster)
{% endhighlight %}

![plot of chunk blank_raster](/images/2014-05-15-rasterizing-shapefiles-in-r/blank_raster-1.png) 

Above, we've set all those values to 1 and the result is just a raster of one value (color). The values inside the raster are stored in a vector of length `nrow * ncol`, so let's set the values equal to the sequence of numbers from `1:nrow*ncol`.



{% highlight r %}
values(blank_raster) <- 1:(100*100)
plot(blank_raster, col=rainbow(50))
{% endhighlight %}

![plot of chunk blank_raster_rainbow](/images/2014-05-15-rasterizing-shapefiles-in-r/blank_raster_rainbow-1.png) 

Pretty cool! So we can see that raster's values are stored going from the top-left to the bottom-right.

## Rasterize the shapefile

The first line here is pretty straightforward but the second line requires some explanation. The `raster` function tries to assign values to the resulting raster cells. Cells inside any of the polygons of the shapefile will have some value, while cells not included in any of the polygons of the shapefile will have the value `NA`. For some shapefiles, values are picked up from the attributes embedded in the shapefile and will result in variation in values (colors). In my case, I want to force all cells corresponding to land to be equal to 1 and leave the rest `NA`.


{% highlight r %}
land_raster <- rasterize(land, blank_raster)
{% endhighlight %}



{% highlight text %}
## Found 127 region(s) and 128 polygon(s)
{% endhighlight %}



{% highlight r %}
land_raster[!(is.na(land_raster))] <- 1
{% endhighlight %}

## Plot the result

Rasters can be plotted directly with the `plot` function because the `raster` package implements its own `plot` method. Here, we also add the shapefile back on top of the raster to see how we did.


{% highlight r %}
plot(land_raster, legend=FALSE)
plot(land, add=TRUE)
{% endhighlight %}

![plot of chunk land_raster](/images/2014-05-15-rasterizing-shapefiles-in-r/land_raster-1.png) 

Looks pretty good! The filled-in yellow area is the new raster. Let's zoom in to see what's going on.


{% highlight r %}
plot(land_raster, legend=FALSE, xlim=c(-170, -120), ylim=c(30, 65))
plot(land, add=TRUE,  xlim=c(-160, -120), ylim=c(30, 90))
{% endhighlight %}

![plot of chunk land_raster_zoomed](/images/2014-05-15-rasterizing-shapefiles-in-r/land_raster_zoomed-1.png) 

Not great. The raster cells are roughly outlining the land but end up being pretty poor approximations in places. Clearly, we might like to improve the spatial resolution of our raster but this is a pretty good start.

Let's the spatial resolution up to see if we can do better.


{% highlight r %}
blank_raster <- raster(nrow = 1000, ncol = 2000, extent(land))
land_raster <- rasterize(land, blank_raster)
{% endhighlight %}



{% highlight text %}
## Found 127 region(s) and 128 polygon(s)
{% endhighlight %}



{% highlight r %}
land_raster[!(is.na(land_raster))] <- 1
plot(land_raster, legend=FALSE, xlim=c(-170, -120), ylim=c(30, 65))
plot(land, add=TRUE,  xlim=c(-160, -120), ylim=c(30, 90))
{% endhighlight %}

![plot of chunk land_raster_zoomed_hires](/images/2014-05-15-rasterizing-shapefiles-in-r/land_raster_zoomed_hires-1.png) 

Much better!

## Bonus: Effect of different raster resolutions

In the above example, I used a 100x100 grid for the raster. Below, I test 20x20, 100x100, 500x500, and 1000x1000 grids together to explore the effect of that part of the process. What resolution do we need to adequately describe the shape of the land?


{% highlight r %}
layout(matrix(1:4, ncol=2, byrow=TRUE))

resolutions <- c(20, 100, 500, 1000)

for(r in resolutions)
{
  blank_raster <- raster(nrow = r, ncol = r, extent(land))
  land_raster <- rasterize(land, blank_raster)
  land_raster[!(is.na(land_raster))] <- 1
  
  plot(land_raster, legend=FALSE, xlim=c(-170, -120), ylim=c(30, 65), main=paste0("Resolution: ", r, "x", r))
  plot(land, add=TRUE,  xlim=c(-160, -120), ylim=c(30, 90))
}
{% endhighlight %}



{% highlight text %}
## Found 127 region(s) and 128 polygon(s)
{% endhighlight %}



{% highlight text %}
## Found 127 region(s) and 128 polygon(s)
{% endhighlight %}



{% highlight text %}
## Found 127 region(s) and 128 polygon(s)
{% endhighlight %}



{% highlight text %}
## Found 127 region(s) and 128 polygon(s)
{% endhighlight %}

![plot of chunk land_raster_grid](/images/2014-05-15-rasterizing-shapefiles-in-r/land_raster_grid-1.png) 

You can see that, by 500x500, we're getting a raster that looks pretty close to the underlying shapefile.
