---
author: Matt Sears
title: A Survival Guide for Legacy Rails Apps
date: 2014-07-28 9:44 UTC
layout: post
categories: ruby
---

Hello, my name is Matt and I love working with legacy Rails apps. Ruby on Rails is now over
[10 years](https://github.com/rails/rails/commit/98cb3e69afd687f7c0d4bc48eabf284da691abcc#commitcomment-4974690)
old. That means there are a lot of (old) Rails applications running out
there. At Littlelines, we've worked on hundreds of Rails projects. Most of them
we build from the ground up, but often we have the opportunity to work with legacy
Rails apps - some as old as 2006! More often than not, we discover these apps
include many many
[common mistakes](http://edelpero.svbtle.com/most-common-mistakes-on-legacy-rails-apps)
made back in the day and it's our job to fix them. <!--more-->Over the eight years of
writing Rails apps, I've picked up a few tips and tricks that can help us get
through the agony of legacy code.

### 1. Take Stock of the Situation

It is impossible to understand the present or prepare for the future unless we
have some knowledge of the past. So first things first, let's take an assessment
of where we're at in terms of test coverage and code quality. If we're lucky
enough to take on a project that has tests, the first thing I do is install
[SimpleCov](https://github.com/colszowka/simplecov) to measure how well our app
is tested. Once I have the SimpleCov report, I'll take a screenshot and save the
report. Then we can use [CodeClimate](http://codeclimate.com) to get an overall
grade on quality and security. CodeClimate will analyze our app and report on
all the hotspots and security violations in the code. Finally, I'll write this
number down and take a screenshot.

Now that we have metrics to work with, we can do some
[Opportunistic Refactoring](http://martinfowler.com/bliki/OpportunisticRefactoring.html). In
other words, always leave code behind in a better state than you found it. The
fun part is seeing how far we can improve the code's test coverage and
quality and we can challenge ourselves to take the score from an F to an A.

### 2. Sharpen the Saw

> If I had eight hours to chop down a tree, I'd spend six sharpening my axe. --
> Abraham Lincoln

As developers, we spend most of our day buried in our text editor. Luckily for
us, most text editors allow us to customize and fine tune it to make it
work more effectively for us. Even better, some editors like Vim and Emacs
allow you to create custom functions to help automate repetitive and
complex tasks. These can be incredibly useful when working with legacy code. One
of my favorite functions converts old Ruby 1.8's hash syntax to 1.9's new
syntax.

![Ruby Hash Converter](/assets/images/journal/ruby-hash-converter.gif)

Some text editors like Vim and Emacs ship with built-in
[Macros](http://en.wikipedia.org/wiki/Macro_recorder) support. Macros allow us
to record keystrokes and play them back. These can be great tools to automate
simpler tasks with less effort. The nice things about Macros is we
don't need to write a function, we just need to hit the record button
and play it back.

Let's take look at an example. Let's say we are upgrading a Rails application
and we discover that it's using the old style of validating ActiveRecord
fields. We can create an ad hoc macro to convert the first line of the
validation code to the new validation syntax and play it back for the next
three lines.

![Emacs Macro and Playback](/assets/images/journal/macro-recording.gif)

### 3. Learn Something New

As soon as we stop try new things, we stop learning. We can always be better
Rubyist and so as a general rule, I try to learn something new when starting a
new project. It doesn't have to be anything huge. In fact, it's usually a small
thing and something that fits with the project. It can be anything from
replacing our view templates with a new template engine like
[Slim](http://slim-lang.com/) or something as small like using Ruby 2.0's new
[keyword arguments](http://robots.thoughtbot.com/ruby-2-keyword-arguments). Most
likely our legacy app is using some old and unmaintained gems. This is a great
opportunity to see what we can replace them with. Head on over to the
[The Ruby Toolbox](https://www.ruby-toolbox.com) or
[Awesome Ruby](http://marcanguera.net/awesome-ruby) and see the latest and
greatest libraries available.

To give you an example, A few years ago I was tasked with upgrading an old Rail
1.2 app to the latest and greatest version. During the upgrade process, I discovered a
lot of embedded SQL and the project owner had complained about how slow the
searching has been on the site. So, I thought it would be a good opportunity to
learn more about how to do full-text searching in Rails. And this lead me to
discover the great [Sunspot](http://sunspot.github.io) gem. With Sunspot, I was
able to eliminate all the embedded SQL and make the search perform much much
faster at the same time.

### 4. Have a Plan

As a rule for every new project, I make a list of things I'd like to accomplished
by the end of the project. It's usually a small list that contains some very
high level goals. In most cases, the goals coincide with making a better Rails
app and me a better a developer in the end. For example, here is a list I made
on my last project.

1. Upgrade application to Rails 4 and Ruby 2.
1. Raise Code Climate GPA to 4.0.
1. Increase test code coverage by 20%.
1. Watch RubyTapas episode on
   [Null Object](http://www.rubytapas.com/episodes/114-Null-Object) and apply it.
1. Try out [Byebug](https://github.com/deivid-rodriguez/byebug) gem and see how
   it stacks up to Pry.
1. Write a new Emacs Lisp function that converts erb to haml across multiple buffers.

### 5. Keep Pushing

As many of you may know, working with legacy projects can be boring and
frustrating. But, we can take steps to make it a little more fun and learn
something new in process. Even when the code is horrendous and we're cursing who
ever wrote this pile of #@$%, we can still learn something new and challenge
ourselves. And it isn't always new tricks or tools we learn, it's also the past
mistakes that teach us. If you commit to taking these steps, you'll improve your
skills at a much faster rate and you'll find yourself stepping out of your
normal routine and applying new solutions that will ultimately lead to you
becoming a better developer.

How about you? If you have any tips for working on legacy Rails apps, please add
a comment below.
