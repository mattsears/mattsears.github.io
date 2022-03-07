---
layout: post
title: Favorite Tools for Working in Ruby / Rails
categories: ruby
date: 2022-02-28 00:00 +0000
---
Over at the Shopify Enginneer Twitter account, an interesting question was posted that got me
thinking about my favorite and most used Ruby/Rails tools. It's nice to see what other devs are
using so I thought I would share with you what I use the most on a daily basis. In a lot of cases,
I've been using the same tools for over a decade.<!--more-->

<center class="py-4">
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">What are your favorite tools for working in <a href="https://twitter.com/hashtag/Ruby?src=hash&amp;ref_src=twsrc%5Etfw">#Ruby</a> or <a href="https://twitter.com/rails?ref_src=twsrc%5Etfw">@Rails</a>?</p>&mdash; Shopify Engineering (@ShopifyEng) <a href="https://twitter.com/ShopifyEng/status/1493608793950896131?ref_src=twsrc%5Etfw">February 15, 2022</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
</center>

### 1. Emacs

Those who know me, could have guessed this one. I've been a Emacs users for over twenty years - ever
since starting out programming in Perl all those years ago. Since then, I've customized and
maintained my [configuration](https://github.com/mattsears/emacs) for web development and more
specifically for Ruby / Rails development.

### 2. Tmux with Tmuxinator

I live in the terminal all day long - writing, coding, notes and
more. [Tmuxinator](https://github.com/tmuxinator/tmuxinator) is by far the most used Ruby gem in my
arsenal and helps me manages all my Tmux sessions with a simple YAML configuration file. Each Tmux
session is a project more-or-less and inside each session I have windows and panes usually dedicated
to a single task or context. Let's take a look at an example, here is a Tmuxinator configuration for
a typical Ruby on Rails project:

```ruby
name: super-duper-project
root: ~/Workspace/active/super-duper
windows:
  - editor: emacsclient -t README.md
  - shell: clear
  - console: rails c
  - testing:
      layout: even-horizontal
      panes:
        - emacsclient -t test/test_helper.rb
        - bundle exec guard
  - logs: tail -f log/development.log
  - workers: dev
```
When I run `tmuxinator super-duper-project` in the terminal, Tmuxinator fires up Tmux and creates six windows in the
project directory:

1. _editor_: Starts and Emacs session by opening up README.md file to get things started.
2. _shell_: Used for mostly running `rake` and `rails` commands.
3. _console_: Starts a Rails console session for code exploration.
4. _testing_: Starts an Emacs session in the test directory and splits the window with `guard` that
   watches for changes in test files and runs tests automatically as I update the code.
5. logs: Tails the development log so I can see requests and errors.
6. _workers:_ Runs commands in the Procfile.dev file like the Rails server, yarn, and background workers.

Here is another configuration for this very website. I use Jekyll for this blog and have three
windows setup. With command `tmuxinator website`, I can jump right into the project, run `bundle exec jekyll draft "My new draft"`, in the shell window, start the
Jekyll server, and start writing.


```ruby
# ~/.tmuxinator/website.yml

name: website
root: ~/Workspace/active/website
windows:
  - editor: emacsclient -t README.md
  - shell:
  - server: bundle exec jekyll serve --drafts --livereload --livereload_port 8888
```

### 3. Minitest

I've written many times about [Minitest](https://github.com/seattlerb/minitest) and it's been my
standard testing framework for a long, long time. It's strength is it's simplicity, which results in
a simpler test suite. Having a simple and straightforward test suite is crucial for long-term
success. Here is an example of a simple, yet beautiful test:

~~~ruby
# frozen_string_literal: true

require 'test_helper'

class DateTimeHelperTest < ActiveSupport::TestCase
  include DateTimeHelper

  let(:date_range) { nil..nil }

  subject { format_date_range(date_range) }

  describe 'with no range at all' do
    it 'does not format date' do
      assert_equal 'Anytime', subject
    end
  end

  describe 'with a date range on the same day' do
    let(:date_range) { DateTime.new(2022, 10, 12, 8)..DateTime.new(2022, 10, 12, 9) }

    it 'formats the date range on same day' do
      assert_equal 'Oct 12, 2022 08:00am - 09:00am', subject
    end
  end
end
~~~

### 4. Guard

As I mentioned in my Tmuxinator config above, I run
[Guard](https://github.com/guard/guard) continuously in the background. Specifically, it watches for
any changes to the code and runs related tests. Here is a real example Guardfile I have in most
projects:

~~~ruby
# frozen_string_literal: true

ignore %r{.git\/*},
       %r{public\/.*},
       %r{solr\/.*},
       %r{vendor\/.*},
       %r{tmp\/.*},
       %r{log\/.*},
       %r{coverage\/.*}

guard(
  :minitest,
  spring: 'bin/rails test',
  all_on_start: true,
  all_after_pass: true,
  grace_period: 3.0
) do
  watch(%r{^app/(.+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^app/controllers/(.+)_controller\.rb$}) { |m| "test/integration/#{m[1]}_test.rb" }
  watch(%r{^app/views/(.+)_mailer/.+}) { |m| "test/mailers/#{m[1]}_mailer_test.rb" }
  watch(%r{^test/test_helper\.rb$}) { 'test' }
  watch(%r{^test/.+_test\.rb$})
end
~~~

When any tests fail, I'm immediately notified and I hop into the 'testing' tmux pane and can see
which tests are failing and fix it fast.

### 5. Amazing Print / Pry

At the same time as I'm fixing tests or writing new tests, each time I save a file, Guard re-runs
the test giving me instant feedback. A lot of the time, I need to see what is being returned and
[Amazing Print](https://github.com/amazing-print/amazing_print) comes in handy for this reason. I
can simply add the line `ap subject` to the test and save the file. Guard will rerun the test and
amazing print will print the results in full color. If I need to dig deeper, I can also drop in
`binding.pry`, and Guard will "suspend" execution and let me [Pry](https://pry.github.io/) open the
code for a closer look.


### 6. Rubycop

[Rubocop](https://docs.rubocop.org/rubocop/1.25/index.html) is a
static code analyzer and code formatter that helps me make sure I'm keeping inline with [best
practices](https://rubystyle.guide/) thus increasing code health and maintainability. I have Rubocop
integrated with my Emacs config that allows me to see in real-time any violations and/or
recommendations on how the code could be written better. Plus paired with extensions like
rubocop-rails, rubocop-performance and rubocop-minitest, I can get recommendations immediately for
specific libraries and frameworks.

### 7. Simplecov

[SimpleCov](https://github.com/simplecov-ruby/simplecov) let's me see how well my tests are covering
the application code. SimplCov produces results in a very well organized html page where I can see pieces
of code that didn't get "touched" marked in a shade of red. I can write tests
specifically that touches that code _or_ remove the code if it's not being used. It some cases, if
the code isn't touched, it means it's not being used and I can remove the code all together keeping
the project nice and tidy.

### Conclusion

There are quite a few other tools that I didn't mention, but the above seven tools form a solid base on
what I use every day for Ruby/Rails development. I've enjoyed this particular setup for over a
decade and will mostly like continue this setup for the next decade.
