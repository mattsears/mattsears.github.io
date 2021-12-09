---
title: Git blogging with Aerial
layout: post
categories: ruby
---

Over the last few years, I have grown tired of maintaining, migrating, and
upgrading blog software, so I've decided to roll my own with Ruby
code. In doing so, I wanted to keep things as simple as possible with
a basic set of features: articles, pages, comments, rss, etc. What I didn't want
is a SQL database or an administration tool. I wanted to write articles in my
text editor of choice (Emacs), in
[Markdown](http://daringfireball.net/projects/markdown/) format, and versioned
with [Git](http://git-scm.com/).<!--more--> So I've ported this site from Mephisto to my
own custom creation. I call it Aerial.

Much inspiration for Aerial has come from
[Marley](http://github.com/karmi/marley), a minimal flat-file blog engine
written in Sinatra. Like Marley, Aerial is built with
[Sinatra](http://www.sinatrarb.com/) and uses plain text files. Unlike Marley,
Aerial doesn't use a SQL database and uses
[Grit](http://github.com/mojombo/grit) to retrieve article and comment files
from a Git repository.

#### So how does it work?

Articles and comments are stored as plain text files in a local Git
directory. Aerial parses each file and converts them the Article and Comment
objects with their own set of attributes such as title, body, tags, and
author. For example, this article looks something like this:

    Title      : Git blogging with Aerial
    Tags       : projects, ruby, git, sinatra
    Published  : 03/28/2009
    Author     : Matt Sears

    Over the last few years...

Since Aerial reads the articles from the Git repository, the contents of article won't display in the browser unless the changes are committed to Git. Same goes for comments.

#### Working with remote repositories

Aerial uses local and remote Git repositories to sync data between the production web server and your local environment. For example, when comments are submitted on the production web server, they are checked for Spam via [Akismet](http://akismet.com/) and saved to the same directory as the article. Then, the new comment file is added to the production web server's repository and pushed to the remote repository (Github in my case). To pull in user comments to our local environment, simply use the pull command:

    git pull

Now we have all the comments that users have submitted.

#### Getting Started

For Aerial to work, you'll need Git installed and the following RubyGems:

    sudo gem install sinatra grit rdiscount haml

Grab the [source code](http://github.com/mattsears/aerial) from Github.

A small configuration file in config/config.yml is used to store information about your blog. You can add your info now or leave it as is and it will still work. To setup and run Aerial, we need to run the boostrap Rake task:

    rake bootstrap

This will install the necessary directories (specified in the config.yml file), javascript files, and insert a sample article to get you started. If every goes smoothly, Aerial should be up and running at:

    http://localhost:4567

Keeping in spirit with minimalism, all the pages use [Haml](http://haml.hamptoncatlin.com) for the templating engine. Of course, you may change this to the templating engine of your choice.

#### Creating new articles

Create a new folder in the app/articles directory.  You can name this folder anything you want, but it may be helpful to number them so they display in the order you want them to. For example, the folder for this articles looks like this:

    app/articles/011-introducing-aerial

Next, create a text file with the extension '.article' and save it to the new folder.  The '.article' file extension let's Aerial know that this file should be converted to an Article object.  The name of the article will be the article's permalink. Remember, the article will not display on the site until it's committed to the git repository. When the article is completed, we can push it to the remote repository with the push command:

    git push

Now, we're ready to deploy it.

#### Deployment

Deployment tasks are handled with [Vlad the Deployer](http://rubyhitsquad.com/Vlad_the_Deployer.html). A simple deployment script is located at config/deploy.rb. It assumes your running Apache and Phusions Passenger, but you can edit this file with your own settings. Future enhancements may include auto-syncing with post-receive hooks so that 'git push' will make Aerial update itself, but for now we can deploy with a simple rake task:

    rake deploy

This is by no means a comprehensive introduction. If you have any questions or run into any problems, please drop me a line.
