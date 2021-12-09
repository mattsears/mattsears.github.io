---
author: Matt Sears
title: Rake Reset
layout: post
categories: ruby
date: 2014-05-08 00:00 +0000
---
This week I want to show you a simple Rake task I've been using for years. It's
one of the very first things I do when starting a new Rails project. I call it
`reset` and it's purpose is to completely tear down our development environment
and rebuild it from scratch. Here is what it looks like: <!--more-->

~~~ ruby
desc "re-build our development environment"
task reset: :environment do
  return unless Rails.env.development?

  Rake::Task["db:rebuild"].invoke
  Rake::Task["tmp:clear"].invoke
end
~~~

Pretty simple right? As you can see, we're rebuilding the database and the
running `tmp:clear` at the end which removes the cache, session, socket and pid files
from the tmp directory. Let's take a closer look at the `db:rebuild` task:

~~~ ruby
namespace :db do
  desc "build the db and populate it with sample data"
  task rebuild: :environment do
    return unless Rails.env.development?

    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
    Rake::Task["db:test:prepare"].invoke
    `yes | rake sunspot:reindex`
  end
end
~~~

We completely obliterate the development database, run our migrations, and seed
our database with sample data. In this case, we're also going to re-index our
Solr instance to make sure it is up-to-date.

Now we can run `rake reset` in our Rails project and we're ready to go. I like
this rake task for a couple of reasons:

1. If you're in a situation where you're scratching your head and things aren't
   quite working right, we can run this task it get us back to square one.

2. Getting new developers setup and ready to go on a project is a snap.


Like I said, I've been using this rake task for years and come to rely on it
heavily. Just knowing that I can always get back pristine development
environment has saved me countless hours.

Enjoy!
