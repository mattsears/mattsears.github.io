---
layout: post
title: Easy Multiple Account Management for Heroku
date:  2011-01-11 14:46:34 -0800
categories: rails
---

Recently, I migrated all of my personal and [business](http://littlelines.com) sites
to [Heroku](http://heroku.com). Heroku, as you may know, is a fantastic
service for hosting ruby applications. Oh, and it's free!

Like a lot of folks, I keep work and personal items such
as email, bank accounts, github, etc in separate accounts. <!--more-->
Heroku doesn't really place nice with multiple accounts.

So how to do we effectively manage multiple Heroku accounts?

#### Prerequitites

The following assumes you are on the Mac OS or *nix system, own
multiple Heroku accounts, and have installed the Heroku gem. I should
also be point out that you will need to create separate ssh
public keys for each account.

#### Custom Ruby Script

One option is we can use a script such as Keith Gaddis
[describes](http://collectiveidea.com/blog/archives/2010/08/06/heroku-ing-with-multiple-personalities)
over at the Collective Idea blog. With his [switcher](https://gist.github.com/511789) script, we can
switch between two accounts like this:

    ruby switcher.rb personal
    ruby switcher.rb work

This essentially swaps the credentials file (used by the Heroku gem
for authentication) for the account you want to
use. This works well enough, however this can be tedious especially if
you switch between work and personal projects frequently.

#### Enter Heroku Accounts Plugin

David Dollar of Heroku recently released an official Heroku
plugin called [heroku-accounts](https://github.com/ddollar/heroku-accounts). With
this plugin, we can switch Heroku accounts automatically.

To get started, we first install the plugin:

    heroku plugins:install git://github.com/ddollar/heroku-accounts.git

The installation process will download the plugin from github and save
it to the ``~/.heroku/plugins`` directory. Now, we can
setup each of our Heroku accounts with ``add`` command:

    heroku accounts:add work

and for our personal account, we can run:

    heroku accounts:add personal

The ``add`` command will ask you for your Heroku email address and
password for each account. The plugin will maintain
your account credentials in the ``~/.heroku/accounts`` folder in your
home directory. (Passwords are not saved in plain text)

To assign a project to a specific Heroku account, we run the following
command in the project root:

    heroku accounts:set personal # or work

This will assign a Heroku account to the project by adding an 'account' variable
to the project's git config file.

#### Celebrate

Hooray! Now we can switch Heroku accounts automatically. Awesome.
