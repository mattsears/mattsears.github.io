---
title: Ruby Blocks as Dynamic Callbacks
layout: post
date:   2011-11-27 14:46:34 -0800
categories: ruby
---

Callbacks are a great technique for achieving simplicity and flexibility. Simply put,
a callback is a block of code passed as an argument to a method.  In Ruby, code
blocks are everywhere and Ruby makes it trivial to pass a block of code to
methods.<!--more--> For example:

```ruby
def foo(bar, &block)
  callback = block
  callback.call(bar)
end

foo(5) {|x| x * x} # => 25
```

But what do we do when a method needs two blocks of code or more? Consider the
classic case where we want a method to execute a block of code if an action
succeeds or call different code if an action fails.

In this article, I will demonstrate how we can pass multiple blocks to a method and
with some metaprogramming, we can achieve a dynamic callback mechanism with just
a few lines of code.

Let's add a method called `callback` to the Proc class:

```ruby
class Proc
  def callback(callable, *args)
    self === Class.new do
      method_name = callable.to_sym
      define_method(method_name) { |&block| block.nil? ? true : block.call(*args) }
      define_method("#{method_name}?") { true }
      def method_missing(method_name, *args, &block) false; end
    end.new
  end
end
```

That's it! The above `Proc#callback` method simply yields an anonymous class
with methods defined to handle our callbacks. This allows for the capability of
creating and storing dynamic callbacks, which can later be looked up and
executed as needed.

Notice anything unusual? We're using the `===` operand to invoke the
block. `Proc#===` is an alias for `Proc.call`. Anything on the right side of
`===` acts as the proc's parameter. Normally, this is to allow a proc object to
be a target of a `when` clause in case statements, but we're using it as a super
simple way of invoking our anonymous class.

Let’s try it with something useful. Let’s say we’re writing something which
needs to happen in an all-or-nothing, atomic fashion. Either the whole thing
works, or none of it does.  A simple case is tweeting:

```ruby
def tweet(message, &block)
  Twitter.update(message)
  block.callback :success
rescue => e
  block.callback :failure, e.message
end
```

The `tweet` method accepts a message string and &block parameters. We call
`callback` on the block and give it a name. Any name will work :success, :error,
:fail!, whatever. In addition, we can pass arguments to the blocks (more on that
later). Now we can provide a status if the tweet was successful or not:

```ruby
tweet "Ruby methods with multiple blocks. #lolruby" do |on|
  on.success do
    puts "Tweet successful!"
  end
  on.failure do |status|
    puts "Error: #{status}"
  end
end
```

The advantage here is that we define our own mini DSL. We don't need to worry
about passing too many or unexpected blocks. We could have easily said
`where.success` or `on.error` or `update.fail!`. Also note the `on.failure`
block includes a `status` parameter - this contains the exception message
captured in the `tweet` method above. So if Twitter was down for whatever
reason, the `on.failure` block would be invoked and printed 'Error: Twitter is
down or being upgraded'.

Bonus: In addition to wrapping code in blocks, our `Proc#callback` method
defines boolean style methods. So we could have call the tweet method like this
if we wanted to:

```ruby
tweet "Ruby methods with multiple blocks. #lolruby" do |update|
  puts "Tweet successful!" if update.success?
  puts "Sorry, something went wrong." if update.failure?
end
```

Put the `Proc#callback` method in a utility library and your code will look neat and tidy.

As always, I welcome your thoughts and feedback. Let me know what you think of
the techniques shown here, or share your own favorite code block tricks.
