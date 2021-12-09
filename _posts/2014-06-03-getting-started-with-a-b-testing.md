---
author: Matt Sears
title: Getting Started With A/B Testing
date: 2014-06-03 15:20 UTC
layout: post
categories: ruby
---
To be perfectly honest, this is a subject that I have been ignoring for the
longest time. I thought A/B testing was just a buzz word that fancy marketers
throw around at unsuspecting clients. Recently, I have been proving my past self
wrong and starting to see the light.

It first started out with asking myself: "How can I help my clients succeed
after their product has launched?" In my programmer's mind, my first thought was
how do we know what works and what doesn't? <!--more--> In this article, I'm sharing with
you what I've discovered about A/B testing.

### What is A/B Testing?

First, let me explain what A/B testing is all about. Simple put, we're testing
two (or more) versions of something and seeing what our visitors respond to
more. The "something" can be a website, a mobile app, or even non-digital things
such as product packaging or business cards.

In this article, I'm strictly speaking of testing websites - how one design (A)
compares to the second design (B). By doing this, we're splitting our visitor
traffic into separate designs and measuring which design performs best.

### Where to we start?

So you might be wondering how you can start A/B testing on your own
projects. I was wondering the same thing too and had a little trouble at first
thinking of things I should be testing. It really comes down to what you
want your visitors to do when they visit your website. For example, if we run an
online store, you may want your visitors to add an item to a shopping cart or if you
run an online service, you want your visitors to sign up for an account.

So how can we encourage our users to take the desired steps? Or maybe another
question to ask is what is discouraging our visitors? Is it the our marketing
copy, colors in the design, is our navigation menu confusing?

All these questions can be answered with a couple A/B tests. If we're not sure what
is driving our visitors away we can start setting up a test that changes a few
elements on the page. For example, here are some other things that we may want
to test:

1. Marketing Copy
1. Call to Action buttons e.g. color, wording, placement.
1. Button or Link placement on the page.
1. Photography

### Example Experiment at Littlelines

As a simple experiment, I created an A/B test for the Littlelines homepage. At
the bottom of the page is our call to action button that takes our visitors to
the contact page. My goal is to increase the frequency of clicks for our call to
action button. In other words, I want to encourage our visitors to contact
us. Thus, our conversion goal is to get visitors to click the button. So I setup
an experiment using three distinct messages on the button as displayed below.

1. This first button is the original button. It conveys a nice and friendly
message. Here we're assuming that our visitors have project they need help with.

{%
  picture
  a-b-testing/lets-talk-about-your-project.png
  --img class="w-1/2 flex m-auto pr-5"
%}

2. Now for our first variation, let's change things up a little. Instead of
  inviting visitors to talk to us, we're going ensure them that contacting us is
  free and there is no risk involved.

{%
  picture
  a-b-testing/book-a-free-consultation.png
  --img class="w-1/2 flex m-auto pr-5"
%}

3. Finally, our second variation, we want to express a little urgency. Something
that will let our visitors know that they better hurry and contact us because
they may lose there spot if they don't act fast.

{%
  picture
  a-b-testing/reserve-your-spot.png
  --img class="w-1/2 flex m-auto pr-5"
%}

There you have it. We setup a simple experiment to see which of the three call
to action buttons has the best effect. Okay, so how do we actually run this
experiment in production? Well, there are a lot of choices when in comes to A/B
testing including several open source options such as Facebook's
[PlanOut](http://facebook.github.io/planout/), Etsy's
[Feature](https://github.com/etsy/feature), eCloudera's
[Gertrude](https://github.com/cloudera/gertrude). And for Ruby on Rails
projects, there's [Vanity](https://github.com/assaf/vanity) and
[Split](https://github.com/andrew/split) to name a few.

All of the above A/B tools require some programming knowledge. If your not a
developer, no worries. There are several online services available that make A/B
testing a snap without any technical knowledge required. See
[Visual Website Optimizer](http://visualwebsiteoptimizer.com/) and
[Unbounce](http://unbounce.com/).

In our case, I'm using [Optimizely](https://www.optimizely.com/) to conduct our
experiments. I find Optimizely to be a simple and easy tool that allows you to
dive into A/B testing quickly. And perhaps the best part, it will
collect the data for us and display the results into an easy-to-understand
format. Checkout the results from our Littlelines homepage experiment:

{%
  picture
  a-b-testing/graph.png
  --img class="pr-5"
%}

I've been running this experiment for 13 days. Which begs the question, how long
do we need to run our experiment? We don't want to cut the experiment too early
because we don't want any false positives. It turns out this is not a simple
answer. There are a few onlines resources that can help us including a
[calculator](http://www.evanmiller.org/ab-testing/sample-size.html). Luckily for
us, Optimizely will try to figure this out for us. Notice in top-left section of
the graph above, it states our experiment is "currently inconclusive". This
basically means we have not let our experiment run long enough. Great, we'll
just keep this experiment running until Optimizely tells us otherwise. So far it
looks like our original "friendly" button is leading - it was able to convert
the most of our visitors, but we will have to wait and see if final tally
before we declare a winner.

### Further Reading

Along my A/B journey, I found a few good articles and videos that explain what A/B
testing is and how some companies are using it to their advantage.

1. Mailchimp explains how A/B testing can improve your email marketing campaigns
   [How does A/B Split testing works?](http://kb.mailchimp.com/article/how-a-b-split-testing-works/).

1. Airbnb shows us how they run experiments
   [Expirments at Airbnb](http://nerds.airbnb.com/experiments-at-airbnb/) and
   the common pitfalls they ran into and how we avoid them.

1. Although not specifically about A/B testing, Cap Watkins'
   [Etsys Product Design Principles](https://vimeo.com/76639385) talk at
   [HybridConf 2013](http://hybridconf.net/) gives us a little insight on how Etsy
   uses A/B testing to see which designs convert better.

### Conclusion

Hopefully, I've illustrated how A/B testing can be a great tool to help inform
us on decisions and how easy it is to get started today. If your using A/B
testing on your projects, please share in the comments. I would love to know
more about how well or not well it's working for you.
