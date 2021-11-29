---
layout: post
title: To Gem Or Not To Gem
author: Matt Sears
categories: development
date: 2021-11-29 15:21 -0800
---
When it comes to running a Rails project for the long-term, one strong indicator
for success is gem _decision_. I've worked on dozens and dozens of Rails
applications during my time as a consultant and often times a client's project
would be either be suffering from poor performance or is too difficult to
maintain and progress has slowed down to crawl. <!--more-->The first thing I typically
looked at is the Gemfile. It's more common than not that there are _too many_
gems.

This is especially true for new Rails developers - too eager to reach for a gem
for every new feature they write. When there are too many gems, the app will run
slower since there are more lines of code to process. Why is this? Typically gem
authors need to accommodate for a variety of factors. Factors like Ruby
versions, database types, or web frameworks like Sinatra. What this means is
there is a lot of extra code in that gem that will never be used by our
application. Many times, I've seen a Rails app just use on method from a single
gem!

### Three questions I ask when deciding to use a gem or not:

#### 1. Is it currently being maintained?

Take a look at the source code on Github or Gitlab. What is the date of the last
commit? Does the author explicitly state that the gem is no longer maintained?
If there hasn't been a commit in the last year, it's most likely not being
updated. So we can't expect bug fixes or security updates in the near future. It
will may also mean that we risk preventing other gems from being updated. For
example, running `bundle update` on our Rails project may not run since the
unmaintained gem depends on other older gem versions.


#### 2. What is the size of the gem?

How big is the project? What other gems does it depend on? Browse through
the source and get a rough idea about the amount of code. There might be a lot
of code to handle a variety of environments _or_ it may not be as organized or
designed well. Why is this important? More gems means more Ruby and more Ruby
means a slower running app.

#### 3. How much of the gem do we need to utilize?

What do I need from this gem to get our feature complete? Do we just need one or
two small things to get the job done or do we need something more comprehensive like
[Devise](https://github.com/heartcombo/devise) or
[ViewComponents](https://viewcomponent.org). Obviously, if we need a gem that is
more comprehensive, then we should use the gem. A gem like ViewComponents is a
large project and would require a lot of code to mimic the functionality and
it's more or less closer to the core of our application.

### Case Study

I recently had the need for the ability to save a _draft_ of data before saving
it to the real database record. Simply put, I need to stash a set of data that
mocked my real ActiveRecord model's schema and save it to a database until the
users decides to publish it.

After some searching, I found a couple gems that do exactly what I
need. However, none of them have been updated in the last year. The most popular
of the gems is actively looking for a new maintainer and it has a bunch of
overly complicated code that I most likely will never need. In my case, I only
need to save a draft and publish the draft - that's it.

If you haven't guessed by now, I've decided not to use any gem and write my own
code to do what I need. I'm going to approach this as a reusable code in
case we want to use drafts in our other models. I've also looked at the source
code of the gems to get ideas and use them in my own code.

Let's create a concern called _Draftable_:

~~~ruby
# apps/models/concerns/draftable

module Draftable
 extend ActiveSupport::Concern

 included do
   has_one :draft, as: :draftable, dependent: :destroy
 end

 def has_draft?
   Draft.exists?(draftable_id: id)
 end

 def save_draft(params = nil)
   return false if new_record?

   if has_draft?
     update_draft(params)
   else
     create_draft(params)
   end
 end

 def publish!
   ActiveRecord::Base.transaction do
     self.attributes = draft.reify.attributes
     self.save
     self.reload
     draft.destroy
   end
 end

 private

 def create_draft(_params = nil)
   with_transaction_returning_status do
     draft ||= Draft.new
     draft.object = ActiveSupport::JSON.encode(attributes)
     draft.draftable_id = id
     draft.draftable_type = self.class.name
     draft.save
   end
 end

 def update_draft(params = nil)
   with_transaction_returning_status do
     values = ActiveSupport::JSON.decode(draft.object)

     params.each do |key, value|
       values[key.to_s] = value
     end

     draft.object = ActiveSupport::JSON.encode(values)
     draft.save
   end
 end
end
~~~

We've made this concern so that any model can have a _draft_. Here, we're
storing data in the `object` field using JSON objects. We do this with a
polymorphic relationship to a Draft model:

~~~ruby
# app/model/draft.rb

class Draft < ApplicationRecord
  belongs_to :draftable, polymorphic: true

  validates :object, presence: true

  def reify
    without_identity_map do
      attrs = ActiveSupport::JSON.decode(object)
      attrs.each do |key, value|
        if draftable.respond_to?("#{key}=") && !key.end_with?("_count")
          draftable.send("#{key}=", value)
        end
      end
      draftable
    end
  end
end
~~~

Now we can make any model have a draft. For example, let's say we're building a
blog and we have a Post model that holds the article. I can simply include a
`Draftable` module in my model:

~~~ruby
# app/models/post.rb

class Post < ApplicationRecord
  include Draftable
  ...
end
~~~

With that, we can do things like `post.save_draft(body: 'First draft of the
article')` to save a draft and `@post.publish!` to save the draft data to the
`posts` table.

To summarize, the point of creating `Draftable` is to illustrate the decision
_not to use_ a gem even if one exists. With roughly a hundred lines of code (not
counting our tests), we're able to complete our feature and extend our app
functionality by allowing any model to have a draft. In addition, we're not
dependent on another gem or it's dependencies. We're using **less** Ruby and so  our
app is lean and more maintainable.
