---
layout: post
title: Forget Service Objects, Write Command Objects in Ruby
description: ''
author: Matt Sears
categories: development
date: 2021-02-07 13:53 -0800
---
The term "service object" can mean different things depending on who you talk to
or what project you inherited, hence why I put them in quotes. Since there's not
really a "Rails Way" to put business logic, it was common to shove everything
into Active Record models. When that went awry, the concept of service objects
came onto the scene and provided a pathway for storing domain logic in plain
Ruby objects. <!--more-->

Then something went terribly wrong with service objects - they got *too
fancy*. Sadly, there's whole host of libraries designed to organize domain
logic, but lose sight on what makes Ruby great - _readability_. Libraries like
[dry-rb](https://dry-rb.org/) that attempt to organize domain logic in a
standard way, but end up making the code much more difficult to understand IMHO.

I much prefer the concept of Command objects. Command closely aligns with
_procedure_. After all, that's all we're doing anyway - in between the controller
and the models, we're running procedures, or commands, and returning the
result. I'm going to show you how I use command objects in my Rails apps
with the help from [Mutations](https://github.com/cypriss/mutations), a gem that
takes a somewhat hands-off approach to composing business logic by _not_ obscuring
business logic with fancy abstractions, rather it merely providing helpful tools to
write clear business operations in ruby objects.

Let's say you've been assigned a new project. The project has a page that
allows you to search and sort a list of users from the database. To your horror,
you discover the following code:

~~~ruby
class UsersController < ApplicationController
  def index
    sql = "active=true"
    sql += "order by #{params[:order_by]}" if params[:order_by]
    sql += "and name=#{params[:name]}" if params[:name]
    sql += "and email=#{params[:email]}" if params[:email]
    @users = User.where(sql)

    respond_to do |format|
      format.html
      format.json
    end
  end
end
~~~

We've probably all seen code like this (and much worse) time and time again. We not only have business logic in
our controllers, it's also not flexible, not secure, hard to test, and
definitely error-prone. Let's clean this up by calling our new a command object instead.

~~~ruby
class UsersController < ApplicationController

  def index
    search = Users::Search.run(params)

    respond_to do |format|
      if search.success?
        @users = search.result
        format.html
        format.json
      else
        render search.errors
      end
    end
  end
end
~~~

Much cleaner and readable. We've replaced all the ugly forged sql code with just one line, a command called
`Users::Search.run(params)`. This Ruby object will contain all the code
necessary to search users based on the arguments we send to it and return the results. By the way, I
organize command objects in Rails projects like this:

~~~sh
app/commands/users/create.rb
app/commands/users/delete.rb
app/commands/users/search.rb
...
~~~

It's pretty clear what these commands do and we can even read it backwards,
_search users command in application_ and _create user command in application_,
and it's still obvious what these objects do.

For our user search, we have a couple options on how we
search for users in our database. We could use a 500 horsepower engine like
[Elastic Search](https://www.elastic.co/elasticsearch/), but we're going to keep
it simple and use ActiveRecord for now. The nice thing about using a command
object, is that it hides the implementation from our caller. So all the code
that calls `Users::Search.run(params)` (i.e. Api controllers, background jobs,
rake tasks, whatever) won't need to change. This could be important if later we decide to
search for users using Elastic Search instead. Here's what our command object
looks like:

~~~ruby
# /app/commands/users/search.rb

class Users::Search < Mutations::Command
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  optional do
    string  :name
    string  :email, matches: VALID_EMAIL_REGEX
    string  :order_by
    string  :direction, in: %w(desc asc)
  end

  def execute
    build_scope
  end

  private

  def build_scope
    scope = search_names(User)
    scope = search_emails(scope)
    scope = sort_users(scope)
    scope.all
  end

  def search_names(scope)
    return scope unless name

    scope.where(name: name)
  end

  def search_emails(scope)
    return scope unless email

    scope.where(email: email)
  end

  def sort_users(scope)
    return scope unless order_by

    scope.order("#{order_by} #{sort_direction}")
  end
end
~~~

Let's breaks this down. First, we're inheriting from `Mutations::Command` class which
gives us the nice set of tools. Most notably the `optional` block that allows us
define all the parameters that we will accept. Conversely, we could force the
caller to pass in certain parameters with the `required` block. In these
blocks, we can also validate and sanitize the input so if anything unexpected is
passed to our command object, Mutations will declare it failed. For example,
let's try to run the command with an improper email address:

~~~sh
>> search = Users::Search.run(email: 'wrong@format')
>> search.success?
false
>> search.errors.message
{
  "email" => "Email isn't in the right format"
}
~~~

Another cool thing about the arguments we pass in, is that they become more or
less variables that we have access to during the execution. For example,
`email`, and `name` have values that we can use anywhere in our class. In this
case, we're searching the database for users based on information we sent
in. We're doing this by building our ActiveRecord
[scopes](https://guides.rubyonrails.org/active_record_querying.html#scopes)
dynamically - chaining scopes if our (optional) parameters have values.

The `execute` method is where we put the code that we want to run when
`Users::Search.run` is called. Mutations stays out of our way here, giving us
the freedom to do what we want in this method. There's no fancy DSL that we have
to follow and no binding BS. The result of this method will be assigned to a
variable called `result`. In our case, we're building ActiveRecord scopes and at
the end, returning `scope`. Let's see it in action.

~~~sh
search = Users::Search.run(name: 'Matt', order_by: 'created_at',
  direction: 'desc')

>> search.result
[#<User:0x00007fa2ccd234hC>,<User:0x00007fa2ccd123sac>, <User:0x00007fa2ccdsad9w>]

>> search.result.class
User::ActiveRecord_Relation < ActiveRecord::Relation

>> search.result.to_sql
"SELECT \"users\".* FROM \"users\" WHERE \"users\".\"name\" = 'Matt'
    ORDER BY created_at desc
~~~

Service objects may have their place, but I much rather see a project with a set
of commands that clearly defines intent both in logic and in naming.
