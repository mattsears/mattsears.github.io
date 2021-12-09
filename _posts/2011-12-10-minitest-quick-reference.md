---
layout: post
title: Minitest Quick Reference
date:  2011-12-10 14:46:34 -0800
categories: ruby
---

UPDATE: I've added a new section on stubbing with MiniTest and a few
helpful comments to the code samples.

[MiniTest](https://github.com/seattlerb/minitest), as the name suggests, is a
small and fast unit testing framework. Shipped with Ruby 1.9, MiniTest supports
a complete suite of testing capabilities such as TDD, BDD, mocking, and benchmarking.<!--more-->

This quick reference aims to demonstrate MiniTest's main concepts and
provide real world examples to get you acquainted quickly. Let's start with
MiniTest::Spec.

### MiniTest::Spec

Provides RSpec-like matchers and contexts right out of the box.

```ruby
require 'minitest/autorun'

describe Hipster, "Demonstration of MiniTest" do

  # Runs codes before each expectation
  before do
    @hipster = Hipster.new
  end

  # Runs code after each expectation
  after do
    @hipster.destroy!
  end

  # Define accessors - lazily runs code when it's first used
  let(:hipster) { Hipster.new}
  let(:traits) { ["silly hats", "skinny jeans"] }
  let(:labels) { Array.new }

  # Even lazier accessor - assigns `subject` as the name for us
  # this equivalent to let(:subject) { Hipster.new }
  subject { Hipster.new }

  it "#define" do
    hipster.define.must_equal "you wouldn't understand"
  end

  it "#walk?" do
    skip "I prefer to skip"
  end

  describe "when asked about the font" do
    it "should be helvetica" do
      @hipster.preferred_font.must_equal "helvetica"
    end
  end

  describe "when asked about mainstream" do
    it "won't be mainstream" do
      @hipster.mainstream?.wont_equal true
    end
  end
end
```

#### Matchers (must | wont)
In most cases you can switch between `must` for positive expectations and `wont`
for negative expectations.

Assertion                | Examples
:------------------------|:----------------------------------------------------|
`must_be`                | `labels.size.must_be :==, 0`
`must_be_close_to`       | `traits.size.must_be_close_to 1,1`
`must_be_empty`          | `labels.must_be_empty`
`must_be_instance_of`    | `hipster.must_be_instance_of Hipster`
`must_be_kind_of`        | `labels.must_be_kind_of Enumerable`
`must_be_nil`            | `labels.first.must_be_nil`
`must_be_same_as`        | `traits.must_be_same_as traits`
`must_be_silent`         | `proc { "no stdout or stderr" }.must_be_silent`
`must_be_within_epsilon` | `traits.size.must_be_within_epsilon 1,1`
`must_equal`             | `traits.size.must_equal 2`
`must_include`           | `traits.must_include "skinny jeans"`
`must_match`             | `traits.first.must_match /silly/`
`must_output`            | `proc { print "#{traits.size}!" }.must_output "2!"`
`must_respond_to`        | `traits.must_respond_to :count`
`must_raise`             | `proc { traits.foo }.must_raise NoMethodError`
`must_send`              | `traits.must_send [traits, :values_at, 0]`
`must_throw`             | `proc { throw Exception if traits.any? }.must_throw Exception`

### MiniTest::Unit::TestCase
Provides a rich set of assertions to make your tests clean and readable.

```ruby
require 'minitest/autorun'

class TestHipster < MiniTest::Unit::TestCase
  def setup
    @hipster = Hipster.new
    @labels  = Array.new
    @traits  = ["silly hats", "skinny jeans"]
  end

  def teardown
    @hipster.destroy!
  end

  def test_for_helvetica_font
    assert_equal "helvetica!", @hipster.preferred_font
  end

  def test_not_mainstream
    refute @hipster.mainstream?
  end
end
```

#### Assertions (assert | refute)
Toggle between `assert` for positive assertions and `refute` for negative assertions.

Assertion            | Example
:--------------------|:----------------------------------------------------------|
`assert`             | `assert @traits.any?, "empty subjects"`
`assert_empty`       | `assert_empty @labels`
`assert_equal`       | `assert_equal 2, @traits.size`
`assert_in_delta`    | `assert_in_delta @traits.size, 1,1`
`assert_in_epsilon`  | `assert_in_epsilon @traits.size, 1, 1`
`assert_includes`    | `assert_includes @traits, "skinny jeans"`
`assert_instance_of` | `assert_instance_of Hipster, @hipster`
`assert_kind_of`     | `assert_kind_of Enumerable, @labels`
`assert_match`       | `assert_match @traits.first, /silly/`
`assert_nil`         | `assert_nil @labels.first`
`assert_operator`    | `assert_operator @labels.size, :== , 0`
`assert_output`      | `assert_output("Size: 2") { print "Size: #{@traits.size}"}`
`assert_raises`      | `assert_raises(NoMethodError) { @traits.foo }`
`assert_respond_to`  | `assert_respond_to @traits, :count`
`assert_same`        | `assert_same @traits, @traits, "It's the same object silly"`
`assert_send`        | `assert_send [@traits, :values_at, 0]`
`assert_silent`      | `assert_silent { "no stdout or stderr" }`
`assert_throws`      | `assert_throws(Exception,'is empty') {throw Exception if @traits.any?}`

### MiniTest#stub
Minitest provides a simple `stub` method we can use to return a pre-determined value.

```ruby
require 'minitest/autorun'

describe Hipster, "Demonstrates stubbing with Minitest" do

  let(:hipster) { Hipster.new }

  it "trendy if time is now" do
    assert hipster.trendy? DateTime.now
  end

  it "it is NOT trendy if 2 weeks has past" do
    DateTime.stub :now, (Date.today.to_date - 14) do
      refute hipster.trendy? DateTime.now
    end
  end
end

```

### MiniTest::Mock
A simple and clean mock system. There two essential methods at our disposal:
`expect` and `verify`.


```ruby
require 'minitest/autorun'

# Make all of our Twitter updates hip
class Twipster
  def initialize(twitter)
    @twitter = twitter # A Twitter API client
  end

  def tweet(message)
    @twitter.update("#{message} #lolhipster")
  end
end

# Uses Mock#expect and Mock#verify
describe Twipster, "Make every tweet a hipster tweet." do
  before do
    @twitter  = MiniTest::Mock.new # Mock our Twitter API client
  end

  let(:twipster) { Twipster.new(@twitter) }
  let(:message) { "Skyrim? Too mainstream."}

  it "should append a #lolhipster hashtag and update Twitter with our status" do
    @twitter.expect :update, true, ["#{message} #lolhipster"]
    @twipster.tweet(message)

    assert @twitter.verify # verifies tweet and hashtag was passed to `@twitter.update`
  end
end
```

### Resources
1. [MiniTest on Github](https://github.com/seattlerb/minitest)
2. [MiniTest Rdoc](http://docs.seattlerb.org/minitest)
3. [Using MiniTest::Spec with Rails](http://metaskills.net/2011/03/26/using-minitest-spec-with-rails)
4. [Ruby Inside: A MiniTest::Spec Tutorial: Elegant Spec-Style Testing That Comes With Ruby](http://www.rubyinside.com/a-minitestspec-tutorial-elegant-spec-style-testing-that-comes-with-ruby-5354.html)

I hope you found this quick guide valuable. Please let me know if you'd like
to see anything else included and feel free to ask questions or give feedback
in the comments section.
