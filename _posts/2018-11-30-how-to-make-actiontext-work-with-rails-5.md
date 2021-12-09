---
author: Matt Sears
title: How to Make Action Text Work with Rails 5.2
date: 2018-11-30
layout: post
categories: ruby
---

When DHH
[announced](https://www.youtube.com/watch?v=HJZ9TnKrt7Q&feature=youtu.be) [Action Text](https://github.com/rails/actiontext), I really like the idea of making rich text editors easier to use especially
when throwing photos in the mix. It's come up multiple times in projects over the years and it's never been easy to do.

It just so happens, I was working on a project that needed a simple blog and
would be perfect match for Action Text. Only problem was it was a Rails 5.2
application and Action Text is really slated for Rails 6, which won't be released
until next year. So I decided to see if I can make it work. <!--more--> Long story, short - it works.

### 1. Installation

In Rails 5.2, The ActionStorage performs image processing on the fly and uses MiniMagick by default. However in Rails 6, ActiveStorage is moving to the [ImageProcessing](https://github.com/janko-m/image_processing) gem instead. But for our purposes, we just need the Action Text gem installed.

~~~ruby
gem "actiontext", github: "rails/actiontext", require: "action_text"
~~~

And then run the installer and migrations:

~~~ruby
rails action_text:install
rails db:migrate
~~~

### 2. Update Action Text's Blob Partial

The Action Text installer will add a view partial `_blob.html.erb` that's
responsible for displaying the images. We'll need to modify this partial since
Action Text assumes we're using ImageProcessing's `resize_to_fit` option to
resize photos, but that's not available to us yet. We need to use the
`variant` option available to us in Rails 5.2 ActiveStorage. These variants are
used to create thumbnails, fixed-size avatars, or any other derivative image
from the original.

~~~erb
<figure class="attachment attachment--<%= blob.representable? ? "preview" : "file" %> attachment--<%= blob.filename.extension %>">
  <% if blob.representable? %>
    <%= image_tag(blob.variant(resize: "800x600")) %>
  <% end %>

  <figcaption class="attachment__caption">
    <% if caption = blob.try(:caption) %>
      <%= caption %>
    <% end %>
  </figcaption>
</figure>
~~~

Now, this worked for the most part. I was able to click an drag photos over to
the trix editor and verified that it was uploading files via
ActiveStorage. Pretty cool!

![Hotwire Gif](/assets/images/journal/action-text-in-action.gif)

#### 3. Avoid PG:UniqueViolation Errors  ####

But, I noticed some issues with other ActiveStorage enabled models unrelated to Action Text, in
particular, models with `has_many_attached` included. Looking at the logs, I saw some
exceptions:

~~~
PG::UniqueViolation: ERROR: duplicate key value violates unique constraint "index_active_storage_attachments_uniqueness" DETAIL: Key (record_type, record_id, name, blob_id)=(ActionText::RichText, 349d05dd-cc7c-4e51-973d-24ff9e382e10, embeds, 1e794d34-6a14-4a80-9aeb-d31e6e1a1494) already exists. : INSERT INTO "active_storage_attachments" ("name", "record_id", "record_type", "blob_id", "created_at") VALUES ($1, $2, $3, $4, $5) RETURNING "id"
~~~

It wasn't saving all the attachments for a model. I had no idea why this was
happending, but I verified it worked fine in Rails 5.2. Digging deeper, it looks
like this entire part of ActiveStorage was rewritten for Rails 6 and that means
Action Text was written to work with that, understandably. The exception is
being raised
[here](https://github.com/rails/rails/blob/5-2-stable/activestorage/lib/active_storage/attached/many.rb#L21)
in `activestorage`. It's attempting to create new records when the records
already exists, which unfortunately means we're going to have to override this
method with a little monkey patching:

~~~ruby
# config/initializers/monkey_patches.rb

module ActiveStorage
  class Attached::Many < Attached
    def attach(*attachables)
      attachables.flatten.collect do |attachable|

        if record.new_record?
          attachments.build(record: record, blob: create_blob_from(attachable))
        elsif !record.is_a? ActionText::RichText
          attachments.create!(record: record, blob: create_blob_from(attachable))
        end
      end
    end
  end
end
~~~

We simple check if the record is of type `ActionText:Rich` before attempting to create new attachments, otherwise we just skip it. And that did the trick.
