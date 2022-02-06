---
title: Quick git add, commit, push, and deploy
layout: post
date: 2008-08-11 00:00 +0000
categories: ruby
---


Last week, I was preparing a presentation and found myself doing a lot of quick
fixes and deployments to prepare a web application for a demonstration.  I
thought instead of running the following four commands each time: <!--more-->

~~~shell
    git add .
    git commit -a -m 'A description of the change'
    git push
    cap production deploy
~~~

It would be nice if I could do all of the above with just one command.  So I
created this shell script:

~~~shell

push() {

  # Defaults
  MINLEN=25
  DIRTY=false
  DEPLOY="production deploy"
  REMOTE_REPO = "origin master"

  # Check if we have any untracked files
  if git status | grep -q "modified:"
  then
     DIRTY=true
  fi

  # Make sure there is a message with the commit
  if [ -z "$1" ] && (test $DIRTY == true)
  then
    echo "You must specify a message with your commit"
    return
  elif [ ${#1} -lt $MINLEN ] && (test $DIRTY == true)
  then
    echo "Your message must have at least $MINLEN letters."
  return
  fi

  # Commit all the changes by default
  if (test $DIRTY == true)
  then
     echo "Adding new files to Git repository"
     git add .

     echo "Commiting to local Git repository"
     git commit -a -m "$1"

     # Push changes if a remote repository exists
     if git remote | grep -q "origin"
     then
        echo "Pushing changes to remote repository"
        git push $REMOTE_REPO
     fi
  fi

  # Deploy changes via Capistrano
  if ls | grep -q Capfile
  then
     cap $DEPLOY
  fi
}
~~~

The `push` function will first check to make sure you supplied a description if
any recent changes were made.  Second, it will commit all the code and push it
to the remote repository (if one exists).

If none of the code was modified or added, it will skip the Git commands and
simply run the Capistrano deploy command and not require a description for the
changes.

To use this script, copy and paste the above function to the end of your
~/.bash_profile file. To run it, simply run the 'push' command.

~~~shell
push "The description for the committed changes."
~~~

That's it!  All the code is added, commited, pushed, and deployed.
