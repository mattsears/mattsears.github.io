---
layout: post
title: 'Hotwire, ViewComponent, and TailwindCSS: A New Era in Ruby On Rails Development'
categories: development
date: 2021-03-30 10:11 -0700
---
The world has changed a lot in the past year, no doubt. This includes some big
changes on how we will build Ruby on Rails applications going forward. Late last
year, the Basecamp/Hey team released [Hotwire](https://hotwire.dev/), a new way
how our front-end and back-end code work together. Hotwire is a collection of
tools that allows to build single-page (like) apps with much less
Javascript. Most notable tool in Hotwire's collection is
[Turbo](https://turbo.hotwire.dev/), which provides most of the plumbing for
delivering html to the browser without full-page reloads. <!--more--> When
paired with [Stimulus](https://stimulus.hotwire.dev/), we can sprinkle in a
little Javascript into your HTML and make our apps really responsive.

{% picture hotwire-new-era.jpg %}

On the west coast, The Github team is working on a new technique for building
user interface components called
[ViewComponent](https://viewcomponent.org/). With this gem, we can say to
goodbye to logic-ridden partials and replace them with smaller, bite-size
nuggets of common user interface elements such has buttons, links, flashes,
popups, and more.

And then we have [TailwindCSS](https://tailwindcss.com/), a CSS framework that
is design to work in html classes instead of traditional CSS stylesheets. With
Tailwind, you style elements by applying pre-existing classes directly in the
HTML. This can take a little getting use to, since if you're like me, I've been
knee deep in stylesheets for over twenty years. But after working with Tailwind
for just a little while, it's a game changer. You're able to build out nice
looking interfaces without even creating a CSS file.

An overwriting common theme these tools have is _we're working more directly in
the html_. We're able to build great looking websites with function by just
adding attributes and elements. This eliminates a ton of Javascript and CSS
files, that let's face it, hindered productivity. I've been working with these
three tools for a few months now and it's feels like I finally have a great way
to organize and test user interfaces like never before.

To illustrate the power of these three tools, I'm going to show you how to make
any normal link fetch the results from the server and display the results in a
popup modal box. Meaning, the application will make a request to the address
specified in the `href` attribute, the server will render the html, and the
browser will display the html in a popup - all without full page refresh and
very little Javascript. For example, let's start with this `link_to`:

~~~erb
<%= link_to "Edit Profile", '/profile', data: { "turbo-frame": "popup_modal" } %>
~~~

It's a normal plain link, with one exception of the `data-turbo-frame`
attribute. When we assign this attribute to a link, it essentially tells Turbo
to intercept the click on `<a href>` and prevents the browser from
following it, instead makes a requests to `/profile` on the server using fetch, and then
renders the HTML response inside the `turbo-frame`. You can learn more about
this on the Turbo's handbook in the section [Turbo Drive: Navigate within a
persistent
process](https://turbo.hotwire.dev/handbook/introduction#turbo-drive-navigate-within-a-persistent-process)

The `turbo-frame` we want in question is our popup modal. We're going to use
*just one* view component for all of our popups. Meaning we will not be required
to wrap the `/profile` html around a modal on the server - freeing us to use
view in other ways if we choose too.

Okay, first let's build our view component for our modal popup. Below are three files we need.


1. The ruby code for our component. In this case, we're just accepting the name of the component which we will in turn use in our template.

    ~~~ruby
    # app/components/modal_component.rb

    class ModalComponent < ViewComponent::Base

      def initialize(name:)
        @name = name
      end

    end
    ~~~

2. The html code for our component. Notice the `<turbo-frame>` element. We're assign the id of the frame to the name we pass into our component.

    ~~~erb
    <!-- app/components/modal_component.html.erb -->
    <div data-controller="modal-component">
      <div data-popup--modal-target="container"
           data-action="click->modal-component#closeBackground keyup@window->modal-component#closeWithKeyboard"
           class="hidden absolute transform transition-all inset-32 overflow-y-auto flex justify-center" style="z-index: 9999;">
        <div class="max-h-screen w-full relative">
          <div class="bg-white rounded-md shadow pt-3">
            <div class="hidden sm:block absolute top-0 right-0 pt-4 pr-4">
              <button type="button" class="btn-round" data-action="click->modal-component#close">
                <span class="sr-only">X</span>
              </button>
            </div>
            <turbo-frame id="<%= @name %>" data-modal-component-target="frame" src="" target="_top"></turbo-frame>
          </div>
        </div>
      </div>
    </div>
    ~~~

3. And the Javascript we need to do basic things with our modal like dismissing and the actual popping.

~~~js
// app/components/modal_component_controller.js

import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['container', 'frame', 'loader'];

  connect() {
    this.observer = new MutationObserver(this.frameMutated.bind(this))
    this.observer.observe(this.frameTarget, { attributes: true, childList: false, characterData: false   })

    // The HTML for the background element
    this.backgroundHtml = this._backgroundHTML();
  }

  disconnect() {
    this.observer.disconnect()
    delete this.observer
    this.close();
  }

  frameMutated () {
    if (this.frameTarget.hasAttribute('busy')) {
      this.loaderTarget.classList.remove('hidden');
      this.open();
    } else {
      this.loaderTarget.classList.add('hidden');
    }
  }

  open() {
    // Insert the background
    document.body.insertAdjacentHTML('beforeend', this.backgroundHtml);
    this.background = document.querySelector(`#${this.backgroundId}`);

    // Unhide the modal
    this.containerTarget.classList.remove("hidden");
  }

  close(e) {
    e.preventDefault();

    // Hide the modal
    this.containerTarget.classList.add("hidden");

    // Remove the background
    if (this.background) {
      this.background.remove();
      this.background = null;
      this.frameTarget.innerHTML = "";
    }
  }

  closeBackground(e) {
    if (e.target === this.containerTarget) {
      this.close(e);
    }
  }

  closeWithKeyboard(e) {
    if (e.keyCode === 27 && !this.containerTarget.classList.contains("hidden")) {
      this.close(e);
    }
  }

  _backgroundHTML() {
    return '<div id="modal-background" class="fixed top-0 left-0 w-full h-full " style="background-color: rgba(0, 0, 0, 0.4); z-index: 98;"></div>';
  }
}

~~~

This is standard Javascript for handling popups, with on exception: We need the
popup to appear when it's contents change. At the time of the writing of this
post, there is no way to trigger events on the front-end when Turbo completes
it's request. So when Turbo replaces the contents with the response from
`/profile`, we need that to trigger the popup to, _popup_.

With our new view component, we can call component in our application layout just before the end of `</body>` element:

~~~erb
<!-- /app/views/layouts/application.html.erb -->
   ...
  <%= render(ModalComponent.new(name: "popup_modal")) %>
</body>
~~~

With that we have a nice popup modal styled with Tailwind and organized as a
View Component ready to respond when it's content is changed. Buried in this
popup is the `turbo-frame` with the same id as the target in the link `<%=
link_to "Edit Profile", '/profile', data: { "turbo-frame": "popup_modal" }
%>`. With this link, Turbo will make a request to `/profile`, render the html on
the server, and return the response inside the turbo-frame (matching the
'popup_modal' id) that we declared in our component.

The last piece of the puzzle is the server-side code. In our show action, we
simply just need to declare `turbo_stream` format like this:

~~~ruby
class ProfileController < ApplicationController
  ...

  def show
    respond_to do |format|
      format.turbo_stream
    end
  end
end
~~~

Then in our turbo_stream template, we instruct turbo to
[update](https://github.com/hotwired/turbo-rails/blob/main/app/models/turbo/streams/tag_builder.rb#L56)
the contents of the "popup_modal" turbo-frame, to update the contents with the
html inside the block:

~~~erb
<!-- /app/views/profiles/show.turbo_stream.erb -->

<%= turbo_stream.update "popup_modal" do %>
  <div class="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden transform transition-all sm:my-9 sm:align-middle sm:w-full sm:p-6" role="dialog" aria-modal="true" aria-labelledby="modal-headline">
    <div class="sm:flex sm:items-start">
      <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
        <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-headline">
          Hello from the server!
        </h3>
        <div class="mt-2">
          <p class="text-sm text-gray-500">
            This HTML was rendered on the server and sent over the wire with Hotwire.
          </p>
        </div>
      </div>
    </div>
  </div>
<% end %>
~~~

When this is returned from the server, Turbo on the front-end will update the
contents in our `<turbo-frame id="popup_modal"...</turbo-frame>` that we've
declared inside our view template that resides at the bottom of the application
layout. In our Stimulus controller
`app/components/modal_component_controller.js` (shown above), we've included a
`MutationObserver` that basically watches to see if any of the html code
changes. When it does, it will _popup_ our modal. Let's see it in action:


![Watch Rich Text Editor in action](/assets/images/journal/hotwire.gif)

So now whenever we want to display content in a popup, we just need to add the
`data: { "turbo-frame": "popup_modal" }` data attribute to any link and it will
magically work - no extra code necessary.

~~~erb
<!-- Display the sign up page in a popup -->
<%= link_to "Sign Up", '/sign_up, data: { "turbo-frame": "popup_modal" } %>

<!-- Display the login form in a popup -->
<%= link_to "Login", '/login, data: { "turbo-frame": "popup_modal" } %>
~~~

I know this is a lot to digest and there's a lot I didn't cover. I will continue to write more about Hotwire in the
very near future as I'm very excited about it's possibilities. Check back soon!
