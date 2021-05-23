---
layout: post
title: Kill N+1 Queries For Good with Strict Loading
description: ''
author: Matt Sears
categories: development
date: 2021-05-23 14:17 -0700
---
Starting with [Rails 6.1](https://github.com/rails/rails/pull/37400), we can set
a `strict_loading` configuration option that, when `true`, will throw an error
if your code attempts to lazy load any associations with out strictly including
the association in the ActiveRecord query.

#### A brief history on N+1 queries and Ruby on Rails

Rails has a long history of scaling problems and a big cause of this is slow
database performance of N+1 queries. Rails makes it super easy to get data from
a database and magically have all of it at your finger tips. <!--more--> For
example, let's say we have the following model associations:


~~~ruby

class User < ApplicationRecord
  has_many :activities
  ...
end

class Activity < ApplicationRecord
  belongs_to :user
  ...
end
~~~

Let's say we want to get a list of activities for the first user:

~~~ruby
@user = User.first
~~~

~~~erb
<% @user.activities.each do |activity| %>
  <p><%= activity.description %></p>
<% end %>
~~~

The log files indicates it takes six SQL queries to get the information we want,
six queries! That may not sound like a lot, but as users grow and activities
grow, that's going to be a tremendous burden we place on the database.

~~~ruby
User Load (0.5ms)  SELECT "users".* FROM "users" LIMIT $1  [["LIMIT", 1]]
Activity Load (0.4ms)  SELECT "activities".* FROM "activities" WHERE "activities"."id" = $1 LIMIT $2  [["id", 16], ["LIMIT", 1]]
Activity Load (0.4ms)  SELECT "activities".* FROM "activities" WHERE "activities"."id" = $1 LIMIT $2  [["id", 16], ["LIMIT", 1]]
Activity Load (0.3ms)  SELECT "activities".* FROM "activities" WHERE "activities"."id" = $1 LIMIT $2  [["id", 3], ["LIMIT", 1]]
Activity Load (0.3ms)  SELECT "activities".* FROM "activities" WHERE "activities"."id" = $1 LIMIT $2  [["id", 27], ["LIMIT", 1]]
Activity Load (0.4ms)  SELECT "activities".* FROM "activities" WHERE "activities"."id" = $1 LIMIT $2  [["id", 16], ["LIMIT", 1]]
~~~

Rails took it upon itself to load the activity records for us because we didn't
explicitly say we needed activity data in our initial call to get the
users. This is called `lazy loading` and it's the default behavior in Rails. To
provide relief for our database, we get around the default behavior and [eager
load](https://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations)
associations by adding an `includes` statement:

~~~ruby
@user = User.includes(:activities).first
~~~

Now our logs indicate that we went from _six_ SQL queries, to just _two_. And it
will stay at two even as the activities grow.

~~~ruby
User Load (0.4ms)  SELECT "users".* FROM "users" LIMIT $1  [["LIMIT", 1]]
Activity Load (0.4ms)  SELECT "activities".* FROM "activities" WHERE "activities"."id" IN ($1, $2, $3)  [[nil, 16], [nil, 3], [nil, 27]]
~~~

Clearly, eager loading is crucial to save on precious database cycles and makes
our application more scalable. There are tons of articles out there about eager
loading so I won't go into anymore detail. Instead, I want to focus on how can
we be sure we're using eager loading throughout the development life-cycle.

### Make strict loading the default to prevent any lazy loading of database records

To turn off lazy loading completely we just make a simple configuration change:

~~~ruby
# config/application.rb

config.active_record.strict_loading_by_default = true
~~~

Now, if we attempt to lazy load any records, Rails will throw an error,
preventing our application from running and possibly tests from passing until we
eager load every query that requires data from an association.

~~~ruby
ActiveRecord::StrictLoadingViolationError (`User` is marked for strict_loading.
  The `Activity` association named `:activity` cannot be lazily loaded.)
~~~

This is a sure-fire way of preventing N+1 queries and forces us to really think
about the data we need when writing code. This is my default setting on any new
Rails projects and it does take some time getting used to. When I first starting
using strict loading, it was a little frustrating to start. My tests wouldn't
pass and the some load pages wouldn't render. I was tempted to remove the
setting, in particular in test mode so my tests would pass again. But, I
resisted and instead updated my code to eager load records where needed.

A particular trouble spot are test fixtures. For example, the code below uses
[FactoryBot](https://github.com/thoughtbot/factory_bot) for fixtures and there's
no simple way to eager load factories. So we can't get data on associated
models like `user.activities` without getting the
`ActiveRecord::StrictLoadingViolationError` error. To get around this, I eager load
the association data in the `subject`:

~~~ruby
class UserTest < ActiveSupport::TestCase
  let(:user) { create(:user) }
  let(:activity) { create(:activity, user: user) }

  subject { User.includes(:activites).find(user.id) }

  it "has activities" do
    # assert_includes user.activities, activity # throws ActiveRecord::StrictLoadingViolationError error

    assert_includes subject.activities, actvity
  end
  ...
end
~~~

Not exactly as easy as just using the `user` record created from FactoryBot, but
at least now our `subject` has all the data loaded and the results are a faster
test suite since we're using less queries!

#### Updates coming in Rails 7 for strict loading

In the upcoming Rails 7 release, there are more options around strict loading we
can use to fine tune our application. Most notably, the `n_plus_one_only` mode that
allows us to lazily load `belongs_to` and `has_many` associations that are
fetched through a single query, but does not raise an error unless it is a true N+1
query. This will be mostly likely be the default setting I will use since I think it's a
nice trade off between convenience and performance.

~~~ruby
user.activities # Does not raise an error anymore
user.activities.first.client # Raises StrictLoadingViolationError
~~~

We can also set the strict loading option on an associations-by-association
basis. This can be handy if we're working with an existing app and we want to
convert to strict loading over time.

~~~ruby
class User < ApplicationRecord
  has_many :activities, strict_loading: true
end
~~~

I encourage you to try making strict loading the default in your Ruby on Rails
applications. Your databases will thank you.
