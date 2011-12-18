Title         : Minitest Quick Reference
Tags          : ruby
Publish Date  : 2011-12-10 20:38:19
Author        : Matt Sears

Minitest as the name suggests is a small unit testing framework.  Introduced in
Ruby 1.9.2, minitest is incredibly fast and supports a complete suite of testing
capabilities such as TDD, BDD, mocking, and benchmarking.

### Quick Start

```ruby
class User

end
```

### Setup

```ruby
before
after
it
let
subject
create
to_s

message
flunk
pass
skip
```


### Unit Tests

```ruby
assert
assert_block
assert_empty
assert_equal
assert_in_delta
assert_in_epsilon
assert_includes
assert_instance_of
assert_kind_of
assert_match
assert_nil
assert_operator
assert_output
assert_predicate
assert_raises
assert_respond_to
assert_same
assert_send
assert_silent
assert_throws
```

### Specs

```ruby
must_be_empty
must_be_close_to
must_be_within_epsilon
must_be_within_epsilon
must_include
must_be_instance_of
must_be_kind_of
must_match
must_be_nil
must_be
must_output
must_raise
must_respond_to
must_be_same_as
must_send
must_be_silent
must_throw
```

### Benchmarks

### Mocks
