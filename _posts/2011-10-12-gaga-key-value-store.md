---
layout: post
title: Gaga, A Git-Backed Key/Value Store
tags: [git, ruby]
---

Gaga originated from my winning entry in Codebrawl's [Key/Value
Store](http://codebrawl.com/contests/key-value-stores) contest. The challenge
was to write the best key/value storage backend you can think of. Since Git is
fast, reliable, and a great tool for storing source code, I was really
interested in making an easy way to store key/values.

Built with [Grit](https://github.com/mojombo/grit), Gaga supports SET, GET, KEYS,
and DELETE operations. And since it's Git, we can easily enhance it to include
other awesome Git features such as branches, diffs, reverting, etc.

#### Usage

```ruby

@gaga = Gaga.new(:repo => '/path/to/repo')

# SET
@gaga['lady'] = "gaga"

# GET
@gaga['lady'] #=> "gaga"

# KEYS
@gaga.keys  #=> ['lady']

# DELETE
@gaga.delete('lady') #=> 'gaga'

# Remove all items from the store
@gaga.clear
```

That works pretty well. Now, we can harness the power of Git and enhance our data
store. For example, we can get a history log for a specific key:

```ruby
# LOG
@gaga.log('lady')

# Produces:
[
 {"message"=>"all clear","committer"=>{"name"=>"Matt Sears", "email"=>"matt@mattsears.com"}, "committed_date"=>"2011-09-05..."},
 {"message"=>"set 'lady' ", "committer"=>{"name"=>"Matt Sears", "email"=>"matt@mattsears.com"}, "committed_date"=>"2011-09-05..."}
 {"message"=>"delete 'lady' ", "committer"=>{"name"=>"Matt Sears", "email"=>"matt@mattsears.com"}, "committed_date"=>"2011-09-05..."}
]
```

This is just a start. There's still a lot things we can add.  If you are interested in more detailed information, check out the repo
on [Github](https://github.com/mattsears/gaga).
