---
layout: post
title: RubyConf 2008 Wrap Up
date: 2008-12-23 00:00 +0000
categories: ruby
---

This month I headed down to Orlando, Florida for RubyConf 2008. It kicked off
with a delightful (and touching) keynote by Matz. He walked through his own
programming history with languages including the language he got started with
BASIC (the same language I started with). Matz talked about the growing
community and a statistic from Gartner that says there are over a million Ruby
developers and will grow to 4 million by 2012, which is amazing. <!--more--> He finished up
by saying that Ruby is all about love, and included a slide that said "I love
you all".  Below are couple highlights from each day.

> ![Alt text](https://live.staticflickr.com/3161/3018637018_f52208beb8_h.jpg "The Keynote Audience")
Photo credit: [Dan BenJamin](http://www.flickr.com/photos/danbenjamin/3012059619/in/set-72157608762375251/)

Day 1:
------

Gregg Pollack's talk on Scaling Ruby (without Rails) was really good.  He
touched on green and native threads, EventMachine, message queues, and profiling
code with ruby-prof.  My favorite part of the presentation was the performance
tips and tricks of optimizing Ruby code.  His talk is up at EnvyCast and I
definitely recommend it.

Jamis Buck - "Recovering from the Enterprise" was probably my favorite
presentation at the conference.  The main theme of his talk was that working in
the enterprise solves problems differently than those solutions in Ruby.  Jamis
worked in Java (like me) before Ruby and he told a story of how he written a
library for dependency injection for Ruby but realized that he was trying to use
Java solutions in a Ruby world that didn't need it. He said Java is like Legos
and Ruby is like Play-doh and delivered the best quote of the conference "Just
in time, not just in case"

> ![Alt text](https://live.staticflickr.com/3056/3018637924_49750b32fa_h.jpg  "Glenn Vanderburg and Dave Thomas")
Photo credit: [Dan BenJamin](http://www.flickr.com/photos/danbenjamin/3012058753/in/set-72157608762375251/)

Day 2:
------

Effective and Creative Code by Eric Ivancich was awesome.  He discussed how our
minds work while programming - the differences between fascination and direct
attention, the mental fatique and long periods of direct attention can have on
you.  Fascinating stuff.

Yehuda Katz taught us how to write code that doesn't suck with Interface
Oriented Design.  But first, he announced that Merb 1.0 was released just
minutes before his presentation.  Then he went on to say that unit tests are not
regression tests and that writing regression tests should make sure that the API
we are exposing to the world doesn't break while work is being done under the
covers.

> ![Alt text](https://live.staticflickr.com/3046/3037535342_102649e654_h.jpg "The Hall Between Sessions")
Photo credit: [Dan BenJamin](http://www.flickr.com/photos/danbenjamin/3012061855/in/set-72157608762375251/)

Day 3:
------

I saw Neal Ford's talk on Advanced DSLs in Ruby - one of my favorite topics.
This presentation was really good because Neal was very specific on how to build
DSLs in Ruby and not just the basics.  He covered various techniques on writing
DSLs and provided a nice summary of his talk on his
[website](http://www.nealford.com/downloads/conferences/canonical/Neal_Ford-Advanced_DSLs_in_Ruby-slides.pdf).

I sat down next to Dave Thomas to listen to Gregory Brown's talk about Prawn, a
pure Ruby PDF generation library. Prawn is cool, but how Prawn was born was the
most interesting part of the talk. A community funded project called The Ruby
Mendicant Project allowed Gregory to quit his job and work on Prawn full time -
A Ruby community employee.

Overall it was an amazing conference.  It was great to see and talk to people
that I only get to see online.  Looking forward to next year.
