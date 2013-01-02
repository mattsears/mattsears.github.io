---
title: 5 Ruby Gems for Concise Code
tags: ruby
---

At [Littlelines](http://littlelines.com), we have to write a lot of code under strict time constraints. We work in small teams which means that writing clean and concise code is a necessity. When a Ruby library comes along that makes code easier to grasp in a hurry, test, and maintain - we use it. Here are some gems we have in our toolbox:

#### [Formtastic](http://github.com/justinfrench/formtastic)

If you're developing wep apps, more than likely it will include html forms.  Forms can be a time-drain, not to mention very boring to build. Formtastic provides a more concise way of generating form views and includes inline error messages and is semantically rich.

#### [Resource  Controller](http://github.com/giraffesoft/resource_controller)

Resource Controller hides away the RESTful controller boiler plate code and make your controllers skinny. Skinny controllers help you to consolidate your business logic into one place, thus saves time on maintenance and testing.

#### [Search Logic](http://github.com/binarylogic/searchlogic)

Finding data can get messy. Sometimes we run into situations where we are concatenating strings to build SQL statements and this can lead to bugs. Searchlogic works by creating a number of named scopes that can be called on any ActiveRecord model. The best part, you can dynamically call scopes on associated classes and Searchlogic will take care of creating the necessary joins for you.

#### [Alchemist](http://github.com/toastyapps/alchemist)

Occasionally, we work on projects dealing with conversions.  Alchemist is a Ruby library that does conversions for you and thus making your code more readable and easier to maintain. For example:

Instead of:

    miles = 8 * 1609.344 # converting meters to miles

We can write:

    8.meters.to.miles

Alchemist includes a staggering array of conversions including distance, mass, volume, and more.

#### [andand](http://andand.rubyforge.org/)

andand is a handy gem that allows allows natural method chaining for methods that can return nil. This saves a lot of boilerplate code and improves readability. For example:

Instead of:

    @body = (article = Article.find_by_title('test')) && article.body

We can write this:

    @body = Article.find_by_title('test').andand.body

This will call find on the Article class and sends 'body' if the result is not nil. In addition, our methods are guarded from NoMethodErrors is the result is nil.

