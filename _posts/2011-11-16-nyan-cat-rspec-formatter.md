---
title: Nyan Cat RSpec Formatter
layout: post
date:   2011-11-16 14:46:34 -0800
categories: ruby
---

I watch a lot of tests run in a given day. So I figured why not make it more
fun. Inspired by [minitest](https://github.com/seattlerb/minitest)'s pride, and um
cats? I came up with a [Nyan Cat](http://www.youtube.com/watch?v=QH2-TGUlwu4)
inspired RSpec formatter.

Update: After last week's launch, Nyan Cat received a great response from the
Ruby world. Over the weekend, I released version 0.0.2. <!--more-->  It includes a few bug
fixes and some really cool enhancements. Most notably, Nyan Cat now spans
multiple lines. In addition, it displays running totals of passing, pending,
and failed specs. Thanks to everyone who contributed! Checkout the new
screencast below.

```
-_-_-_-_-_-_-_,------,
_-_-_-_-_-_-_-|   /\_/\
-_-_-_-_-_-_-~|__( ^ .^)
_-_-_-_-_-_-_-""  ""
```

### Nyan Cat

Much like [Nyan](https://github.com/kapoq/nyan), Nyan Cat simply creates a rainbow
trail of test results. It counts the number of examples as they execute and
highlights failed and pending specs. The rainbow changes colors as it runs and
if all the specs pass, Nyan Cat falls asleep.  If there are any pending or
failing specs, Nyan cat is concerned and can't sleep.

Here's a short demo of Nyan Cat in action.

<center>
  <iframe
src="http://player.vimeo.com/video/32424001?title=0&amp;byline=0&amp;portrait=0"
width="640" height="480" frameborder="0" webkitAllowFullScreen
mozallowfullscreen allowFullScreen></iframe>
</center>

Installing Nyan Cat is easy. Just install the gem `nyan-cat-formatter` and simply put the options in your .rspec file:

```
--format NyanCatFormatter
```

Checkout the code on [Github](https://github.com/mattsears/nyan-cat-formatter)
and let me know how you like it.  If you run into any issues, please create an
issue on Github and I will be sure to get it fixed. Of course you can always
fork the project and send me a pull request.

Have fun!
