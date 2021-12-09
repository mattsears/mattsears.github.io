---
title: Print Stamps With Ruby!
layout: post
date:   2011-05-15 14:46:34 -0800
categories: ruby
---

I've just released [Stamps](https://github.com/mattsears/stamps) - A Ruby gem for creating postage labels,
calculate the shipping cost of packages, standardize domestic
addresses via USPS CASS certified Address Matching Software, and track
shipments using the Stamps.com Web Services API.<!--more-->

#### Quick Start
First, you will need to register for a (free) developer account at
[Stamps.com](http://developer.stamps.com/developer). Once you receive
your test credentials and integration id, just plug them into the
configuration block:

``` ruby
Stamps.configure do |config|
  config.integration_id = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX'
  config.username       = 'STAMPS USERNAME'
  config.password       = 'STAMPS PASSWORD'
end
```

For a simple test, we can call `Stamps.account` to retreive
information about the account.  By default, Stamps will return all
responses as a Hash.

#### Create a Stamp

First, we need to standardize the shipping address that complies with the USPS address
formatting guidelines:

``` ruby
standardized_address = Stamps.clean_address(
  :address => {
    :full_name => 'The White House',
    :address1  => '1600 Pennsylvania Avenue, NW',
    :city      => 'Washington',
    :state     => 'DC',
    :zip_code  => '20500'
})
```

Now that we have a clean address we can create a new stamp.  The
`Stamps.create!` takes the sender and receiver address along with parameters
on the rate:

``` ruby
stamp = Stamps.create!(
    :rate          => {
      :from_zip_code => '45440',
      :to_zip_code   => '20500',
      :weight_oz     => '6.5',
      :ship_date      => Date.today.strftime('%Y-%m-%d'),
      :package_type   => 'Package',
      :service_type   => 'US-FC'  # Flat-rate
    },
    :to            => standardized_address,
    :from => {
      :full_name   => 'Littlelines',
      :address1    => '50 Chestnut Street',
      :address2    => 'Suite 234',
      :city        => 'Beavervcreek',
      :state       => 'OH',
      :zip_code    => '45440'
    }
)
```

#### Hooray!

That's it! Stamps will return a url of the stamp.  Print it and ship it!

``` ruby
stamp[:url]
```

If you are interested in more detailed information, check out the repo
on [Github](https://github.com/mattsears/stamps).
