---
layout: post
title: Two+ Years Working with Rails
date: 2008-10-12 00:00 +0000
categories: ruby
---

Update: I thought I should give a little background on how I got started with
Rails - when I was attending the SDWest conference in March 2006.  I was at the
Jolt Awards, and saw @d2h receive the award for the best web development tool
for Rails 1.0.  I downloaded Rails that night in the hotel room and was hooked. <!--more-->

This week marks the two year anniversary when I delivered my first professional
Rails app.  Today, I decided to take a look back at the code of that first
project and see what's improved over the past two years.  The result - not bad,
but there were a couple areas that stood out. Here are a few:


1. The controllers in that first project were out of control. Not sure why,
   maybe coming from the J2EE world, my first instinct was to cram everything
   into the controller. It was apparent that the concept of REST wasn't
   completely baked into my brain yet. Not to mention the concept of fat models,
   skinny controllers.
2. Second, the views and Javascripts were a bit unorganized.  I noticed
   excessive conditional logic and messy Javascript code in a few of the pages.
   If I was to re-write the app today, most of it could be cleanup with
   rendering partials with collections and using Low Pro to clean up the
   Javascript.
3. Finally, the sheer lack of plugins for that first project was
   surprising. It's true that the amount and quality of plugins have grown in
   two years, but I believe the lack of awareness was the main cause.

So this made me think of what I would say if I were to advise newcomers writing
their first Rails app.  I would have to say first, if you find yourself writing
code in the controller, then ask yourself "Can I put this logic in the
model?". And also be sure to familiarize yourself with the available plugins
with sites such as [Agile Web Development](http://agilewebdevelopment.com) and
[Github](http://github.com). They can save you a ton of work.
