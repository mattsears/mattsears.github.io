---
author: Matt Sears
title: Getting Started with Ruby on Rails and Kubernetes
layout: post
date: 2020-04-13
categories: ruby
---

## Why should we deploy our Rails applications to Kubernetes?

Traditionally we've deployed our applications to the cloud using services like
Heroku or on virtual private servers on Amazon EC2, Rackspace, or Digital Ocean
using a custom set of [Ansible](https://www.ansible.com/) scripts to automate
the process. This has worked well an still continues to work well, however we
run into issues with scaling our servers to meet users demands and upgrading
hardware and software isn't always easy without  downtime.<!--more-->

Kubernetes offers us a way to deploy and scale our Rails applications like
nothing we've ever seen before. The flexibility and scalability of containers
encourage many developers to move to Kubernetes so we can set up our
infrastructure one time and it will do the scaling and automation for us. There
is a LOT to learn. In this article, we will walk through how to setup and deploy
a simple Rails application via Kubernetes in three parts:

1. Getting Started with Ruby on Rails and Kubernetes
1. [Deploying Ruby on Rails Apps on Kubernetes](/articles/2020/04/08/deploying-ruby-on-rails-apps-on-kubernetes)
1. [Scaling Ruby on Rails Apps with Kubernetes](/articles/2020/04/03/scaling-ruby-on-rails-apps-with-kubernetes)

#### Prerequisites

We're going to need a few tools installed before we get started. I won't go into
too much detail on how to install these since it's very dependent on your local
setup and the lastest instructions can be found on the web. In addition to Ruby
of course, you'll need the following installed:

1. A Ruby on Rails application
1. Kubernetes command-line tool [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
1. A running Kubernetes cluster
   - [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) (local)
   - [Amazon Elastic Kubernetes Service (Amazon EKS) ](https://aws.amazon.com/eks/)
   - [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine)
   - [DigitalOcean Kubernetes](https://www.digitalocean.com/products/kubernetes/).
1. [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) for help with env vars.
1. [Docker](https://docs.docker.com/install/) to build our images

Let's get started!

#### Our Docker image

First thing's first. We need a docker image to deploy to our cluster. Here's a
simple Dockerfile that I use on a lot of our Rails applications:

~~~bash
ARG RUBY_VERSION=2.4.6

FROM ruby:$RUBY_VERSION-slim-buster

ARG PG_MAJOR=11
ARG NODE_MAJOR=11
ARG YARN_VERSION=1.13.0
ARG BUNDLER_VERSION=1.16.1

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_ROOT=/app
ENV LANG=C.UTF-8
ENV GEM_HOME=/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH=/app/bin:$BUNDLE_BIN:$PATH

# Install essentials
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    curl \
    libcurl3-dev \
    libgit2-dev \
    git \
    cmake \
    gnupg2 \
    pkg-config \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

# Add PostgreSQL to sources list
RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

# Add NodeJS to sources list
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -

# Add Yarn to the sources list
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    less \
    libxml2-dev \
    libgssapi-krb5-2 \
    libpq5 \
    libpam-dev \
    libedit-dev \
    libxslt1-dev \
    libpq-dev \
    postgresql-client-$PG_MAJOR \
    nodejs \
    yarn=$YARN_VERSION-1 \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

ENV PATH /app/bin:$PATH

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler \
  && bundle install -j "$(getconf _NPROCESSORS_ONLN)"  \
  && rm -rf $BUNDLE_PATH/cache/*.gem \
  && find $BUNDLE_PATH/gems/ -name "*.c" -delete \
  && find $BUNDLE_PATH/gems/ -name "*.o" -delete

COPY . ./

RUN RAILS_ENV=production bundle exec rake assets:precompile

CMD bundle exec puma -C ./config/puma.rb

~~~

The above Dockerfile will install all the tools we need to run our application which includes Ruby, Yarn, Nodejs, and Postgres to name a few. Please note we're not running a Postgres database server in our Docker image. This is mainly because we're going to be running multiple Rails applications in our cluster and we want just one singular database that all of applications can share. For my application `myapp`, I've created a database cluster in my DigitalOcean account for it's database. With this file, we build image:

    $ docker build -t myapp:build .

Now we should be able to see our images:

    $ docker images

    REPOSITORY      TAG                 IMAGE ID            CREATED             SIZE
    myapp           build               b8df7b665990        7 minutes ago       941MB

Now we have an image to work built locally we need to push the image to an
external services such [Amazon's Elastic Container Registry](https://aws.amazon.com/ecr/). This will be the
place where Kubernetes will eventually pull the image from. In this case, we're
going to use [Docker Hub](https://hub.docker.com/). Docker Hub offers a free
plan for public images so it's a great place to test things out. Once you have an
account, we can push our image like this:

    $ docker login -u 'my docker hub username' -p  'my docker hub password'
    $ docker push DOCKER_USERNAME/myapp:build

Now we have a docker image and it's hosted on the interwebs where our
deployments can get to it eventually. Now we're to start working on our
Kubernetes setup. From here, we're going to assume you have `kubectl` installed
locally and a cluster to work with. In my case, I've created a cluster in my DigitalOcean account and followed it's instructions on setting it up locally. We check this by running:

    $ kubectl config get-clusters

    NAME
    do-nyc3-k8s-myapp-production

If you see your clusters listed, congrats - this means `kubectl` is installed correctly and we have a cluster to work with.

#### Our trusty hammer: Rake

What's truly help me get started with Kubernetes is using tools that I'm
familiar with. We're going to be running a lot of commands in the terminal - too
many to remember in fact. To wrangle these commands and allow us to document the
steps along the way, we're going to enlist our old friend Rake to help us.

For the remainder of this series, we're going to build rake tasks that interface
with our cluster. By doing so, we have a great way to document what we're doing
and the additional bonus of using Ruby and other tools that come with our Rails
application. By end of this series, we will have built all the basic tasks
require to setup, deploy and scale our Rails application.

In our Rails application, let's create a new Rake file called `kube.rake` and
save it in our `lib/tasks/` directory. We're going to start with


~~~ruby
# lib/tasks/kube.rake

# Turn off Rake noise
Rake.application.options.trace = false

namespace :kube do
  desc 'Print useful information aout our Kubernete setup'
  task :list do
    kubectl 'kubectl get all --all-namespaces'
  end

  def kubectl(command)
    puts `kubectl #{command}`
  end
end
~~~

As you can see we added a method `def kubectl` that simply wraps a shell command
`kubectl`. We will expand on this a bit more later, but for now we call this
task to get a list of everyting going on in our cluster. Out of the box, our
cluster will have several components setup for us to support our deployments
(more information about can be found
[here](https://kubernetes.io/docs/concepts/overview/components/))

Let's call our new rake task and see what we get:

    $ rake kube:list

    kube-system   kube-proxy-8m9j4                        1/1     Running   0          109m
    kube-system   kube-proxy-w7hsf                        1/1     Running   0          109m
    kube-system   kubelet-rubber-stamp-7f966c6779-9b2xk   1/1     Running   0          111m
    ...


### We're ready to for the next level

At this point, we have a working docker image hosted on Docker Hub, `kubectl`
talking to our cluster, and our Rake file ready to execute commands for us,
we're ready to deploy our rails application to the cluster. Checkout the next
part in this series: [Deploying Ruby on Rails Apps on Kubernetes](/articles/2020/04/08/deploying-ruby-on-rails-apps-on-kubernetes).
