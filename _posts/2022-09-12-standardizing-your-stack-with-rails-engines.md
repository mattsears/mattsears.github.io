---
title: "Maintainable Rails: A Rails Engine Strategy"
categories: ruby
date: 2022-09-12 08:11 -0700
layout: post
---

If you've ever worked for a company or organization that runs multiple Rails applications, you've
most likely seen these projects using different sets of plugins, front-end frameworks, coding
techniques, test frameworks, etc. etc. Ultimately having a ton of technical debt leading to
heavy context switching slowing progress to a crawl. Most of the time it's inevitable
because keeping multiple applications up-to-date and consistent is a daunting task.<!--more-->

I've seen this countless times in my career when running a consulting company and when I worked for
a big IT company. In this article, I want to share with you one technique I use to help _pay down
the technical debt and pave a path forward_ to a more sound development team using [Rails Engines](https://guides.rubyonrails.org/engines.html).

#### Quick intro to Rails Engines

The term "engine" can be confusing because it's not really anything different than what we've
already been working with. A Rails Engine is a Rails application with some special options that
allow us to "hook" into it. I think of it as a Rails module (like a Ruby module) that we're adding
to our code, but instead of getting additional Ruby methods, we can a whole web application at our disposal.

This means we can pack a whole bunch of common/shared functionality into our engine including
models, controllers, views, and even assets like Javascript, CSS, and image assets.

Let's kicks things off with an example engine. Let's say our company wants to build an engine called `CompanyStack`:

~~~shell
$ rails plugin new company_stack --mountable
~~~

We're going to isolate our engine so that we can namespace our ruby code to avoid any collisions in
naming. This will help our engine be independent from any application that uses it. It's important
to think of our engine as completely separate from any application that uses it. Combined with the
`--mountable` option (above), using the `isolate_namespace` will provide independence we need:

~~~ruby
# lib/company_stack/engine.rb

module CompanyStack
  class Engine < ::Rails::Engine
    isolate_namespace CompanyStack
  end
end
~~~

Now we can include our engine in our Rails application's Gemfile:

~~~ruby
gem "company_stack", path: "../path/to/company_stack"
~~~

Let's say our company has a few Rails applications in production. Upper management is
complaining about the amount of time it takes to ship code. Some of our new engineers
aren't as familiar with older versions of Rails so it's more difficult to assign
team members to projects. Our senior engineers are complaining about the sheer amount of redundant
code across our projects. Our Devops team wants to upgrade our servers, but can't because some
applications can't run on newer versions of Ruby, SSL, Postgres, etc etc. Sound familiar?

What are our goals with making our development team more efficient?

1. Reduce the overall development churn so we can ship new features faster.
1. Provide a clear direction on our company's official technical stack.

####  Using Rails Engines to Define Our Organization Stack

Do we know our company's official technology stack? We hope that it's Ruby, but what about
the gems and libraries we should be using? This is crucial in keeping our applications
consistent. How many times have we come across a project that uses Rspec and another one using
Minitest? It's important to define what and how we should be writing our applications so
that we can keep our code consistent and reduce the context switching. A good place to start is the
`gemspec` file in our engine:

~~~ruby
# /company_stack.gemspec

Gem::Specification.new do |spec|
  spec.add_dependency 'rails', '>= 7.0.3.1'
  spec.add_dependency 'turbo-rails', '~> 1.0.1'
  spec.add_dependency 'hotwire-rails', '~> 0.1.3'
  spec.add_dependency 'pg', '>= 1.3.5'
  spec.add_dependency 'view_component', '~> 2.53.0'
  spec.add_dependency 'redis', '~> 4.8'
  spec.add_dependency 'cssbundling-rails', '~> 1.1.1'
  spec.add_dependency 'jsbundling-rails', '~> 1.0.2'
  spec.add_dependency 'bcrypt', '~> 3.1.18'
  spec.add_dependency 'puma, '~> 5.6'
  ...
end
~~~

Here we are defining that Rails 7 with Hotwire, Postgres, Redis, and Puma as our official stack. We
can include additional gems like Mintest, Devise, Sidekiq - you name it. This is taken from my own
company's official stack and it means all Rails applications that includes the `CompanyStack` engine
must be written with these tools - no Rspec, no Mysql, no fancy Javascript libraries unless
officially approved. If your company's Rails applications are older, then it most likely makes sense
require lesser versions of Rails, say 6 and up until everything is caught up.

#### Central Place for Shared and Common Code

Once we have our engine installed on our Rails applications, we can begin to explore ways to reduce
code redundancy. Of course, each application is unique, but there will always be cases of common
code. For example, most applications has a `User` model and that can be one area to extract common
functionality.

Here's a simplified example: We've looked at a few of our Rails applications and we've noticed that
we're authenticating the User in multiple ways. As an organization, it would be nice that all our
projects authenticate the same way so we know that our applications are secure and up-to-date. We'll
create a Concern in our engine that authenticates a user using email and password.

~~~ruby
# /app/models/concern/company_stack/users/auth

module CompanyStack
  module Users::Utils
    extend ActiveSupport::Concern

    class_methods do
      def login(login, password)
         ...
      end
    end
  end
end
~~~

Now, all we have to do is include the Concern in our Rails application and we instantly have a way
to authenticate user records. Eventually, we can remove the old code from the application and just
use the engine to authenticate our users.

~~~ruby
class User < ApplicationRecord
  include CompanyStack::Users::Authentication
  include CompanyStack::Users::Utils
  ..
end

#=> current_user = User.login("mattsears", "******")
~~~

This is a very simplified example, but hopefully it illustrates the potential in using Rails engines
as a way to cut down technical debt. The nice thing about using Concerns, is that our applications
aren't required to use the new authentication until they're ready i.e. including `include
CompanyStack::Users::Authentication` in our User model. The additional bonus is we don't have to
rewrite the user authentication for any new applications we create.

We're not just restricted to sharing Ruby code either, we can share assets like Javascript and
stylesheets as well. At my company, our official front-end stack is
[Hotwired](https://hotwired.dev) and [TailwindCSS](https://tailwindcss.com) and so we can include
these libraries in our engine's asset pipeline.

~~~javascript
// package.json (in CompanyStack)

{
  "dependencies": {
    "@hotwired/stimulus": "3.0.1",
    "@hotwired/turbo-rails": "^7.1.1",
    "@rails/actioncable": "^6.1.5",
    "@rails/activestorage": "^6.1.5",
    "esbuild": "^0.15.6",
    "postcss": "^8.4.6",
    "postcss-flexbugs-fixes": "^5.0.2",
    "postcss-import": "^14.0.2",
    "postcss-nesting": "^10.1.2",
    "postcss-preset-env": "^7.3.1",
    "tailwindcss": "^3.0.20"
  },
  "scripts": {
    "build:css": "tailwindcss --postcss -i ./app/assets/stylesheets/company_static/application.css -o ./app/assets/builds/company_stack/application.css",
    "build": "esbuild app/javascript/*.* --minify --bundle --outdir=app/assets/builds/company_stack"
  }
}
~~~

Speaking of asset pipelines, we can also include custom stylesheets for example, that match our
company brand _and/or_ we can also include Stimulus controllers that provide common Javascript
functions. Now, all we have to do is include the assets in our applications layouts:

~~~erb

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <!-- CompanyStack Engine's assets -->
    <%= stylesheet_link_tag 'company_stack/application', media: 'all' %>
    <%= javascript_include_tag 'company_stack/application'  %>

    <!-- This application's assets -->
    <%= stylesheet_link_tag 'application', media: 'all' %>
    <%= javascript_include_tag 'application'  %>
    ...
~~~

And now our Rails application includes all of our company's official front-end stack and is ready
to take advantage of all the code that has already been written - keeping our Rails applications not
only using less code, but looking consistent too.

We don't have to stop here either, we can include application helpers, background workers, view
components, and more in our engine.

#### In Review

Hopefully I've illustrated the power as using with Rails Engines as an overall strategy to help your
organization get on the right track with more maintainable applications.  For my company, we've been
using this strategy for a while and it has paid a lot of dividends and I think it can help you're
team too.
