---
author: Matt Sears
title: Quick Wins to Improve Rails Performance
date: 2019-08-10
layout: post
categories: ruby
---

We've all most likely received that dreaded message about our Rails application
being "too slow" or even worse "the page won't load". In a lot of cases, these
issues are difficult to track down because likely it works fine on your
development machine or the production server is working perfectly now. So we're
faced with the challenge of tracking down seemingly random bottlenecks that
happened in the middle of the night.<!--more-->

So what can we do to find this ghost in the machine on Monday morning? In this article, I will share a couple of "quick wins" that I've gathered over the years that's helped me and my team quickly reduce page load times and get your Rails application back on the track quickly.

### 1. Get a copy of production data (if possible)

If it's possible to get a copy of the production database, clone it into your local database and update the `database.yml` file to use it in your development environment. This isn't always possible since the database may contain sensitive data or the size is just too large. If it is possible, do it. A lot of performance issues come from complicated queries with a lot of data and there's no good way to replicate this in our local database.

### 2. You only need two tools

Fortunately for us, there are quite a few tools at our disposal, but I found that only two is all we need to get us going.

1. [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler) This is perhaps the most useful tool we have in our arsenal. It gives us immediate insight into how long your database queries are taking, how fast are views are rendering, how much memory is being used, and much more. And the kicker is that we can use this tool in production to get real results from real data, especially if we're not able to get our hands on the production data.

1. [Skylight](https://www.skylight.io) I like Skylight because the UI makes it easy to digest a lot of data that comes from a single call to a controller action - making it easy to find the action that's taking the longest to process the request. While Skylight works to collect data in production, we can start looking at performance locally. As we release code updates to production, we will easily be able to see if our updates are helping with Skylight's trends and Grading system.


### 3. Let's dig in with rack-mini-profiler

Hopefully, now we have some data to work with, we can use rack-mini-profiler immediately to track down bottlenecks on our local development machine or production if necessary since rack-mini-profile was designed to work in production too. After poking around the site, it tells me that it's taking 2 seconds to load the user index page:

~~~ruby
Executing action: show                               172.6   +408.0  122 sql  62.2
    Rendering: /users/show                           333.3   +580.0  112 sql 84.4
    Rendering: /users/modals/_put_student_on_l...    3.8     +634.0
    Rendering: /users/_user_header                   3.1     +648.0  1 sql   0.4
    Rendering: /users/_warn_on_wrong_universit...    5.3     +655.0  1 sql   1.4
    Rendering: /users/_system_actions                39.3    +733.0  1 sql   34.8
    Rendering: /users/modals/_withdrawal             6.9     +872.0  1 sql   0.6
    Rendering: attachables/_list                     33.6    +968.0  3 sql   0.9
    Rendering: user/_notes                           64.0    +1010.0 2 sql   11.3
~~~

Holy smokes! This page is running 100+ queries on a single page.

### Quick win: Eager loading

We work mostly with Rails' ActiveRecord when it comes to getting data. And it's great. but I see a lot developers often don't pay attention to the number of database queries since we're just writing Ruby. But the amount of queries can really ad up quickly. Looking that the logs we see the following:

~~~ruby
SELECT * from "users";
SELECT * from "notes" WHERE "id" = 100;
SELECT * from "notes" WHERE "id" = 108;
SELECT * from "notes" WHERE "id" = 111;
SELECT * from "notes" WHERE "id" = 2332;
SELECT * from "notes" WHERE "id" = 2323;
SELECT * from "notes" WHERE "id" = 3415;
SELECT * from "notes" WHERE "id" = 345;
SELECT * from "notes" WHERE "id" = 535;
SELECT * from "notes" WHERE "id" = 4565;
~~~

We can fix this with eager loading by telling Rails to more or less pre-load associations ahead of time since we know we will need them in our views. This is a small, quick and fairly safe tweak we can make throughout the application.

~~~ruby
users = Users.active.includes(:notes).limit(100)
~~~

This tells Rails to include `notes` in our query for `users`. Now our query looks like this:

~~~ruby
SELECT * from "users" LIMIT 100;
SELECT * from "notes" WHERE "user_id" IN (100,108,111,2332,2323...);
~~~

This reduces the number of sql queries to just 12 - shaving a full second off the page load time! Not bad for a simple 1-line change. Of course, there's more we can do. I mean, one second page load time is still too long, but at least now our users will see some improvement and save our database countless cpu cycles. We repeat this process on every heave loading page we can find and deploy our updates as soon as possible.

### Let's check Skylight

Meanwhile, Skylight has been collecting data for us and we can start to see some problems bubble up to the service. One thing that immediately sticks out is Skylight says the `Dashboard#index` is allocating a lot of objects for one page. The load time is only 600 mili-seconds which isn't too bad, but this particular page is popular and being called a lot. This is something that we missed locally because only one user testing the application...me!

### Quick win: Less looping

The dashboard is loading every user in the database and rendering hundreds of partials. We can cut this down by immediately by paginating our database results and limiting the amount of looping from 200+ to 25 at time. Also, we can make sure we're only getting the data we need by adding a couple of scopes. This will only return active users and ensure we're not returning duplicates too.

~~~ruby
@users = User.distinct.active.order(:name).page params[:page]
~~~

If we take a closer look at the Dashboard views, we can see that we're rendering our user data into a shared partial using a collection. Fortunately, Rails makes it incredibly easy to cache views. In the case, we simply add `cached: true` at the end like this:

~~~ruby
<%= render partial: 'user', collection: @users, cached: true %>
~~~

Boom, we are now caching partials automatically - now all partials will be written and fetched from our cache - greatly improving our rendering times. We can, again, add this to other pages where heavy-object allocation is happening - thanks Skylight for pointing that out to us!

Alright, so with a couple of hours of debugging and tweaking, we can push out some quick updates to our production server to get things moving faster again. There is, of course, more to be done, but with using the tips described above, we can get our Rails application running quickly while we formulate a plan for an overall performance upgrade effort.
