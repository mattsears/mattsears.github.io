---
author: Matt Sears
title: Seamlessly Navigate Rails Projects With Tmux
date: 2014-09-02 13:00 UTC
layout: post
categories: ruby
---
In last week's [Dayton Ruby](http://daytonrb.com) meetup,
[Chris Chernesky](https://twitter.com/chernesk) spoke about how he uses Tmux for
his everyday Rails development. It was great talk and ever since the meetup,
Tmux has been all the buzz at the Littlelines office.

I've been using Tmux for a few years and it has become an essential
tool for my workflow. Tmux's window and session management
make it a no-brainer for those who live in the terminal.<!--more--> In this article, I
explain a few tmux commands and tools that I use daily to help me
work more effectively across rails projects.

### Setting up Tmux

Let's start off on the right foot. Since we're going to spend most of our day
inside tmux, we might as well configure it to best suit our needs. Here are
just a few tmux configurations that are essential for me.

~~~bash
# Remaps tmux prefix to Control-b
unbind C-b
set -g prefix C-a

# Improve colors
set -g default-terminal 'screen-256color'

# Navigate around panes easily using vim-like keybindings
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Remove administrative debris (session name, hostname, time) in status bar
set -g status-left ''
set -g status-right ''
~~~

The biggest configuration change I made is remapping the default Tmux prefix from
Control-b to Control-a instead. Since I've also remapped my caps lock key to the
control key, this is much more convenient for me.

Now let's take a look at a couple aliases I setup to help navigate
tmux on the command line. With these three aliases we can easily list the
running tmux sessions, join a current session, or kill tmux sessions.

~~~bash
alias tml="tmux list-sessions"
alias tma="tmux -2 attach -t $1"
alias tmk="tmux kill-session -t $1"
~~~

### Killer Rails Project Management with Tmuxinator

Working with a typical Rails project may involve several commands and
long-running processes. For example, we may need to run the web server e.g.
`bundle exec rails server` or we may need to run Sidekiq for our background
workers. Tmux is great for this scenario because we can harness the power of
Tmux's windows and panes to organize these processes in a single screen.

To further make our lives even easier,
[Tmuxinator](https://github.com/tmuxinator/tmuxinator) makes managing Tmux
sessions a snap with the use of simple Yaml files. The best part, it's
a ruby gem so all we have to do is run `gem install tmuxinator` and we're ready
to go. Here is an example of a configuration file I setup for one of my Rails
projects.

~~~ruby
name: website
root: ~/code/website
windows:
  - editor:
      layout: main-vertical
      panes:
        - emacs
        - guard
  - tests: bundle exec rake test
  - console: bundle exec rails c
  - workers: bundle exec foreman start
  - logs: tail -f log/development.log
  - server: mosh deployer@production-server.com
~~~

With this configuration, I just run `mux website` and Tmuxinator will cd
into the project's root directory, create a new (or join an existing) Tmux
sessions, create six windows, kick off emacs and  guard panes, run tests, and start the
background workers. Just one command and we're ready to go to work.

### Switch Projects and Windows with Ease


So now we have our Tmux setup and Tmuxinator helping us with session management,
we can start moving around our various projects. We can do this in a couple
ways: from the command line or within Tmux sessions.

### From the command line:

Getting around tmux sessions on the command line is pretty easy. Using our
aliases we setup earlier, we can use the `tml` command to list the current sessions and
`tma` to join an existing session. We can also use the `mux [project]` command
that Tmuxinator provides to either create a new session or join a session if
it is already running.

![Tmux on the command line](/assets/images/journal/tmux-command-line.gif)

### Within Tmux sessions:

Once we're in a tmux session, getting around windows is easy too. I usually hit
`Command-a [Window #]` to jump to a window or `Command-a w` to toggle a list of
windows to open. But what if I need to switch to another project within Tmux?

Thankfully we can run command `Command-a s` to toggle a list of running sessions
to open. This is a great way to navigate all your projects without leaving
Tmux.

![Tmux on the command line](/assets/images/journal/tmux-session-switch.gif)

### Summary
<a name='summary'></a>

What I really like about this setup is that not only can I navigate projects
easily, but I can setup projects just one time - saving the need to create window
or panes every time. And the kicker, I can hop into one project, make a change, and
hop right back where I left off with just a couple keystrokes.

Do you have any Tmux tips you'd like to share? Please leave us a comment below.
