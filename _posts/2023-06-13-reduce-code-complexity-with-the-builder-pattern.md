---
layout: post
title: A Simple Technique to Improve Complex Methods
date: 2023-06-13 09:13 -0700
---
If you ever run [Flog](https://github.com/seattlerb/flog) or
[Reek](https://github.com/troessner/reek), you've most likely encountered
[TooManyStatements](https://github.com/troessner/reek/blob/master/docs/Too-Many-Statements.md) and
[VeryHighComplexity](http://docs.seattlerb.org/flog/) violations in the results. I use Flog and Reek
continuously to help identify areas of improvement by flagging potential code smells, such as
excessive statements and high complexity early in the development cycle.<!--more-->

In this post, I'll show you a technique I use frequently when refactoring Ruby projects. Let's
take a look at a method I ran across recently that had a very poor quality score.

#### The Problem Method

This particular project is an e-commerce application that uses a rule engine-like way to perform
actions based on a set of rules defined by the store owner. The method below _returns a String
describing what the rule does in plain English_. I've shorten this example for brevity, but you can
clearly see it's a mess.

~~~ruby
# app/models/rule.rb

def build_message
  message = ["When"]
  case self.subject
   when 'shopping_cart'
     if target == 'sum'
       message << "the Cart subtotal value"
     elsif target == 'count'
       message << "the Cart items count"
     end
   when 'inventory'
     message <<  "Stock level"
   when 'product'
     message << "<i>#{product.to_sentence}</i> page"
   else
     message << values.join(', ')
  end

  case self.comparison
   when '>='
     message << "is greater than"
   when '<='
     message << "is less than"
   else
    message << "is equal to"
  end

  message << values.join(',')
  message.join(' ')
end

rule.build_message #=> "When Cart value is greater than 10"
~~~

When we want the rule in plain English, we call `rule.build_message` and get _"When Cart value is
greater than 10"_. After running Flog and Reek, we get two violations right away.

The "TooManyStatements" metric indicates when a method contains an excessive number of statements,
suggesting that it might be performing too many responsibilities. This can lead to increased
complexity, reduced readability, and difficulties in maintaining and testing the code.

The "VeryHighComplexity" issue highlighted by Reek points to methods with excessively high
cyclomatic complexity. Cyclomatic complexity measures the number of independent paths through a
method, indicating how difficult it is to understand, test, and maintain.

#### The Solution: Builder Pattern (by another name)?

To be honest, I don't know if we can technically file this under any of the major [design
patterns](https://en.wikipedia.org/wiki/Software_design_pattern), but it's similar to the [Builder
Pattern](https://en.wikipedia.org/wiki/Builder_pattern) in which we're creating a separate class for
building complex objects. In this case we're building Strings, which are objects in Ruby so it kind of fits.

We're going to create a new class for the purpose of constructing our message string. We're
inheriting our new class from the Builder class which will contain shared helper methods we can take
advantage of.

~~~ruby
# app/builders/rule_message.rb

class Builders::RuleMessage < Builder
  attr_accessor :rule

  def initialize(rule=rule)
    @rule = rule
  end

  def message
    message = ["When"]
    build_subject(message)
    build_target(message)
    build_operators(message)
    build_variables(message)
    message.join(' ')
  end

  private

  def build_subject(message)
    build_shopping_cart(message)
    build_inventory(message)
    build_product(message)
  end

  def build_shopping_cart(message)
    return unless @rule.subject == 'shopping_cart'
    message << "Cart"
  end

  def build_inventory(message)
    return unless @rule.subject == 'inventory'
    message << "Stock level"
  end

  def build_product(message)
    return unless @rule.subject == 'product'
    message << "Product"
  end

  def build_target(message)
    case message.target
    when 'sum'
      message << 'subtotal value'
    when 'count'
      message << 'item count'
    end
    message
  end

  # Translates operators i.e. >= to "Greater than or equal to"
  def build_operators(message)
    message << translate_operator(message.operator) # Helper method from parent Class
  end

  def build_variables(message)
    message << @rule.values.join(' or ')
  end
end
~~~

As you can see, our Builder class is much more clean and straightforward. It defines an abstract
interface for creating the parts of the complex string e.g. message. It solves both
'TooManyStatements' and 'VeryHighComplexity' violation by:

1. Separation of concerns: The Builder class separates the construction logic from the object's
   class, `Rule` in our case, allowing for greater flexibility and maintainability.

2. Improved readability: The pattern makes the construction code more readable by encapsulating the
   **construction steps** within our dedicated Builder class.

3. Simplified message creation: Our Builder class provides a clear and structured way to create
   complex strings with various scenarios, making the code more robust and easier to extend.

Let's see our new Builder class in action:

~~~ruby
class Rule < ApplicationModel
  ...
  def to_s
    Builders::RuleMessage.new(rule: self).message
  end
end
~~~

Here, we're overriding the `to_s` method to display the String version of the Rule object. I don't
always do this, but in this case I think it fits nicely since it is a String representation of the
Rule model.

~~~ruby
rule = Rule.active.last

rule.to_s #=>  "When Cart subtotal value is greater than 10"
~~~

Overall, this technique simplifies construction of building strings in a step-by-step
manner while keeping the creation logic separate and providing flexibility. Whenever I encounter a
complex method that:

1. Has long lines of code.
2. Uses a lot of _if / else_ statements
3. Is hard to follow or read

I highly recommend employing this technique to streamline the code and enhance its quality. I have
extensively utilized this pattern over the years, and it proves immensely valuable when revisiting
the codebase after an extended period. By adopting this approach, it becomes significantly easier to
comprehend the code's functionality and seamlessly incorporate enhancements for future
features. This practice fosters maintainability and ensures a smoother development experience in the
long run. Future Rubyists will thank you 😀.
