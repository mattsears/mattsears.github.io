---
layout: post
title: Defensive Development
date: 2023-01-31 09:08 -0800
---
Much like [Defensive Driving](https://en.wikipedia.org/wiki/Defensive_driving), in which Wikipedia
describes "anticipating dangerous situations, despite adverse conditions or the mistakes of others
when operating a motor vehicle", defensive development is building software that anticipates future
"one-off" features and deployments by having tools to solve problems already in production. <!--more-->

{%
  picture
  chess-match.jpg
  --img class="w-full m-auto"
%}

When I was a technical leader at a big tech company, releasing software to production was a big deal
involving many people and procedures - taking days sometimes weeks. It was particularly important to
have all the i's dotted and t's crossed, otherwise it may take another week to deploy another
release. In some cases, a small bug would slip through or even something smaller like a word
misspelled that would have to wait until the following week or petition for an emergency release.

Another common scenario is an outside department in the company needs a special "view" to the
application so that they can gain access to the software for their own purposes. They typically
would request our team to build a separate section just for them tying up our resources just to
build this special feature instead of focusing on our own customer needs. Does this sound
familiar?

Over many years of taking feature requests working with customers and external teams, you begin to
realize a common set of requests users always ask for post-production. In this post, I want to share
with you what I typically like to include with every piece of software I ship in order to anticipate
future requests and reduce the need to deploy special releases.

#### 1. Administration Tool

By far the best and obvious way to make updates in production without re-deploying code is having an
administration tool in place. This can be for development team eyes only or even allow customers to
make updates as well. In Ruby On Rails applications, there are already a few great plugins that
makes it very easy. Here's just a few examples that have helped my team:

  * Updating production database records like user information.
  * Revoking user accounts or permissions.
  * Removing fake or test account data.
  * Changing the price of subscription plans.

#### 2. A Private API

Building an API in the software can be pretty simple to include. Again, for Ruby on Rails apps,
there are gems that make this simple. Having just a simple API in place and pay big dividends down
the road. When asked to get a special "access" in a lot of cases, you can just provide the API
endpoints and connection details and they can build their own application themselves.

#### 3. Managed Tool for Error Logging

If I had a nickel for every time I got an email saying "the website was down last night" and then
spending hours trying to figure out what happened, well, I'd have a lot of nickels. Having a way to
search log files is a crucial way to track down issues or even false alarms. A lot of the time it's
the hosting provider having network issues. Tools like [DataDog](https://www.datadoghq.com) gives
you the ability to track down errors and when they occur. If anything, it's been a great way to
point out there weren't any issues at all and we can move on to the next task.

#### 4. Healthcheck (aka Smoketest) Page

This is one of the oldest and my personal favorite trick. Often times I will build a page in the application
that only I can get to (i.e. /smoketest) that will give me a basic vitals of the system. For
example:

   * First and foremost, make sure the application is still running.
   * Show the number of active users to make sure the application is database connection is fine.
   * Display the status of connection to third-party api's to check the connection is working.

When getting that dreaded email saying "something's wrong with the site", I'll check the smoketest
page first to make sure all is working or quickly determine the issue.

#### 5. Routine Maintenance Task Page

Similar to the administration tool, having a section in the application where the development team
can queue routine maintenance tasks i.e. Rake tasks, is a great time saver. The folks at
Shopify have a gem for this called [Maintenance Tasks](https://github.com/Shopify/maintenance_tasks)
that works great. Here are some examples of maintenance tasks I've used in production before:

  * Deleting inactive user records to clean up the database.
  * Clearing production cache assets to make sure all cached assets are up-to-date.
  * Re-running scheduled tasks in case there was an outage from the night before.

After your the application has been in production a while and you've implemented tools like listed
above, you'll notice fewer and fewer emergency releases and having more to time focus on adding
value your customers will love.
