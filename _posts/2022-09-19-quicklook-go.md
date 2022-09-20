---
layout: post
title: "Writing QuickLook plugins in Go"
tags: ["til", "macos", "quicklook", "golang", "apache-arrow", "parquet"]
---

I recently wanted to write a [QuickLook](https://support.apple.com/guide/mac-help/view-and-edit-files-with-quick-look-mh14119/mac) plugin for [Apache Parquet](https://parquet.apache.org/) because I'm starting to use it more and more.
There are some neat third-party plugins out there like [QLMarkdown](https://github.com/toland/qlmarkdown) and [QLStephen](https://github.com/whomwah/qlstephen) so I sat down to figure out how to write my own.

My first questions were which programming language I'd have to use and how I could write as little new code as possible.

I first tried to vendor [libarrow](https://github.com/apache/arrow/tree/master/cpp) and link against that but ran into issues making clang happy with the C++17 stdlib (which libarrow targets).
I have a feeling it could be made to work but I went back to the web and found a [neat project](https://github.com/remko/qlmka) that used [Go](https://go.dev/) for the plugin code.
The [Go Arrow implementation](https://github.com/apache/arrow/tree/master/go) happens to be one of the few that is written natively (rather than implementing as a binding to libarrow) so I gave that a shot.


## Making a New XCode Project

To start out, I wasn't able to figure out how to make XCode create a new QuickLook plugin from scratch so I ended up adapting from [QLMarkdown](https://github.com/toland/qlmarkdown).
The important files seemed to be:

- `main.c`: Entrypoint for the plugin. Mostly boilerplate aside from the GUID.
- `GeneratePreviewForURL.m`: Definition and implementation of code for generating our QuickLook preview. This is what I cared about most.
- `GenerateThumbnailForURL.m`: Definition and implementation of code for generating thumbnails for our files. Not used here.

The core bit on the XCode side is essentially the implementation in `GeneratePreviewForURL.h` which implememnts what looks like a fairly reasonable interface in order to get data back to macOS for displaying the preview:

```objectivec
OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url,
                               CFStringRef contentTypeUTI, CFDictionaryRef options) {

  NSString *content = MyFun((__bridge NSURL *)url);

  CFDictionaryRef previewProperties = (__bridge CFDictionaryRef) @{
    (__bridge NSString *)kQLPreviewPropertyTextEncodingNameKey : @"UTF-8",
    (__bridge NSString *)kQLPreviewPropertyMIMETypeKey : @"text/html",
  };

  QLPreviewRequestSetDataRepresentation(preview, (__bridge CFDataRef)[content dataUsingEncoding:NSUTF8StringEncoding],
                                        kUTTypeHTML, previewProperties);

  return noErr;
}
```

So basically I needed to write a function that:

1. Takes a filepath (URL)
2. Returns a string

## Writing the Go Portion

Thanks to [CGo](https://go.dev/blog/cgo), we can easily work with Go and C code at the same time which (I think) is why all of this works so well.

A basic skeleton for the Go code looks like this:

```go
package internal

import ( //... your packages here )

import "C"

//export MyFun
func MyFun(cpath *C.char) (code C.int, outData unsafe.Pointer, outLen C.long) {
	path := C.GoString(cpath)

	var buf bytes.Buffer

    // Now just write data into `buf`

	return 0, C.CBytes(buf.Bytes()), C.long(buf.Len())
}
```

A couple of things to note:

1. The `import "C"` is key here
2. I'm not sure if the `//export MyFun` is required here but I left it in
3. The function you write just needs to write into `buf` which is pretty straightforward in Go

Last, to compile our Go module into something we can tell XCode to link against, we do something I'd never done before with Go:

```sh
go build -buildmode=c-archive -o internal.a ./internal
```

The above produces `internal.a` which is critical for the next step.

## Bringing Both Sides Together

To tell XCode to compile our Objective-C code and to link against `internal.a`, we need to add it under XCode under Build Phases > Link Binary With Libraries.

Depending on what Go code you end up writing, you may need to also add various `.frameworks` until linking succeeds.
One surprising thing I ran into was that using Go's `template/html` package required `Security.framework`.
In total, I ended up linking against:

![Screenshot of Apple XCode showing a user interface of a list of items, headed by the text "Link Binary With Libraries (8 Items)"](/assets/{{page.slug}}/linking.png)

## Wrapping Up

Once built, you can move the result into `~/Library/QuickLook`.
You may have to run `qlmanage -r` and even preview other files to get the new previews to be picked up.
Overally, this is a bit finicky and I wish double-clicking on a `*.qlgenerator` file just prompted you to install it and handled caches for you.

In the end, my preview for Parquet ended up looking like this:

![Screenshot of a QuickLook preview dialog showing a summary of a file named orders_0.1.parquet](/assets/{{page.slug}}/qlarrow-example.png)

I put the full source code for my plugin at [QLArrow](https://github.com/amoeba/QLArrow)
