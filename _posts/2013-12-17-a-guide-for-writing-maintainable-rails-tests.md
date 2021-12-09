---
title: A Guide for Writing Maintainable Rails Tests
date: 2013-12-17 21:49 UTC
layout: post
categories: rails
---

Do you ever feel like you spend most of your day repairing tests in your Rails
app? If you have been building Rails apps as long for as we have, then you know
the importance of a robust test suite. Working with a brittle and slow tests can
really make the most basic tasks difficult. This is especially true for large
Rails apps that have been around for a few years. <!--more-->The good news is that we can
fix this with a few helpful tips I've picked up over the years that can keep
your test suite running smoothly for the long-run.

First, let's define what maintainable means. It can take on a lot meanings, but
let's break it down into three categories:

1. *Tests should be reliable.* When we run our tests over and over; whether it's
   a single test or the entire test suite, we want them to consistently pass or
   even consistently fail. There's nothing more tedious than tracking down
   inconsistencies. I've spent countless hours and sometimes days fixing tests
   that run fine in isolation, but fail when running the complete suite.

2. *Tests should be easy to write.* I confess, when I work with a Rails app that
   has slow or brittle tests, I skip writing new tests all together because I know
   it's too difficult or too time consuming setting up new tests. So it's
   critical that our test suite be straightforward enough to dive right in.

3. *Tests should be easy to understand.* When tests fail, we should be able to
   look at the test code and quickly understand why it's failing and how to
   fix it. The last thing we want to do is waste time staring at code wondering
   "Why is this failing!".

## The Test Environment

Now that we have an understanding of what maintainable tests mean, let's get
started with a solid foundation - the test helpers. Here is what our
`test_helper.rb` might look like:

~~~ ruby
require "minitest/autorun"
require "mocha/setup"
require 'simplecov'
require 'capybara/dsl'
require 'capybara/rails'

SimpleCov.start

module TestHelper
  include Capybara::DSL

  def setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end
~~~

Nice and simple! Let's take a closer at the gems we're using:

**[Minitest](https://github.com/seattlerb/minitest)** - I like to use MiniTest for
writing tests because of its simplicity and it provides a complete set of
testing facilities without the noise. Best of all it's shipped with Ruby 1.9.

**[Mocha](http://gofreerange.com/mocha/docs/)** - When we absolutely _need_ to
mock or stub, I reach for Mocha since it's a good lightweight option. I found
Mocha to be the least fussy when it comes to stubbing.

**[SimpleCov](https://github.com/colszowka/simplecov)** is absolutely essential
  for measuring our code coverage. Our road to lean and mean tests start by
  knowing what has already been tested and what has yet to be tested.

**[DatabaseCleaner](https://github.com/bmabey/database_cleaner)** To avoid
banging our head against bizarre inconsistencies with the test database, we are
going to call on the help from DatbaseCleaner, which ensures that we have a clean database
state between tests.

**[Capybara](http://jnicklas.github.io/capybara)** Capybara is an intuitive web browser
simulation framework that allows us to test how a real user interacts with our web application. It
also comes with a built-in DSL for describing user interactions. We'll use
Capybara extensively for our acceptance tests.

## Achieving Testing Zen

Now that we have a nice setup for our suite, we're ready to start adding
tests. How we approach testing is important if we want to keep our test suite
healthy. We want to write the minimal amount of code required to satisfy our
test cases. The best way to do this is using the Top-Down approach. This brings
us to our first tip.

**Tip #1: Start at the top.** Start with the acceptance tests and drive our
  implementation at the user interface level. This can be a great way to
  prototype our implementation, and starting at the top, we can cover a lot of
  code with little tests. Once we are satisfied with our acceptance tests, we
  can fill-in holes with unit tests for complete public interface coverage.

**Tip #2: Use helper methods to keep your test DRY.** To keep our tests nice and
   neat, extract common setup scenarios into helper methods. For example, if we
   know we have to log into the application to test our app, we can setup a
   handy login method:

~~~ruby
def log_in_user(user)
  User.stubs(:authenticate).returns(user)
  visit "/login"

  within("form") do
    fill_in "login", with: user.login
    fill_in "password", with: "anything"
  end
  click_button "Log in"
end
~~~

**Tip #3: Avoid Copy and Paste.** Sometimes it's so easy to copy and paste code
   from one test to another - especially our setup code. Before you copy and paste,
   ask yourself "Should I move this code to a helper method instead?".

**Tip #4: Don't test what has already been tested.** It may sound simple, but
chances are you've written tests for code that has already been tested without
knowing it. I come across something like this quite often:

~~~ruby
describe User do
  it { should have_many(:orders)}
end
~~~

What exactly are we testing here? Are we just wanting to be extra sure that
we've spelled the `has_many :order` association correctly in the User
model? ActiveRecord associations are well-tested by the Rails test suite, so
there is not need to have this in our test suite.

**Tip #6: Avoid Excessive use of mocks, stubs, and expectations.** Too many
   mocks and stubs can lead to unexpected results and expectations often serve
   no benefit at all and almost always lock you to the internal implementation
   of the thing you're testing, thus making tests brittle. I have seen many
   projects use excessive mocks and often times it's not testing
   anything. Prefer to use real data from the database. The downside of this of
   course, is that our tests may be slower.

**Tip #7: Makes tests fast enough.** We're not focusing too much on speed. Don't get
me wrong, if your tests are slow, you won't be encouraged to write them. So it's
important to keep speed in mind. But in the end, the most important thing we
want is a reliable, understandable code, even if they're not as fast as we'd like
them to be.

**Tip #8: Keep context and describe blocks flat.** Avoid deeply nested describe
   contexts. For example:

~~~ruby
describe "checking out" do

  describe "add items in shopping cart" do
    before do
      add_item_to_shopping_cart(product)
      click_link 'Checkout'
    end
    ...

    describe "pay with credit card" do
      ...
    end
  end
end
~~~

When go too deep in our describe blocks, it's easy to lose sight of the steps
taken in the previous describe blocks. To compound the problem, we can't be sure
of the database state either. Consider breaking describe blocks into separate
tests or even separate files when deep nesting occurs. For our example above,
we'll create a brand new test file for paying with credit card:

~~~ruby
describe "paying with credit card" do
  before do
    setup_shopping_cart_and_checkout
    fill_in_credit_card_fields
  end

  it 'checks for valid promotion codes' do
    fill_in "promo_code", with: 'does not exists'
    click_link 'Place Order'
    assert page.has_content?("Sorry, invalid promotion code")
  end
end
~~~

**Tip #9: Only test public side effects.** If a method changes the internal state, write
  your assertions based on the side effects available to the public. Keep test
  cases to external API - allows us to change internal implementation, while
  ensuring the consumers of your class still work.

And that is it! By following these tips, you're on your way to achieving a happy
and health test suite. If you found this article helpful, you should also
checkout:

1. [Practical Guide to User Testing](http://robots.thoughtbot.com/practical-guide-to-user-testing/)
2. [Rails Testing Pyramid](http://blog.codeclimate.com/blog/2013/10/09/rails-testing-pyramid/)
3. [Minitest Quick Reference](http://mattsears.com/articles/2011/12/10/minitest-quick-reference)

Got any tips to share? Please leave them in the comments.
