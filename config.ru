#!/usr/bin/env ruby
# -*- coding: undecided -*-
require "rubygems"

env  = ENV['RACK_ENV'].to_sym
root = File.dirname(__FILE__)

#if env == :production
  require 'rack/contrib'
  require 'rack-rewrite'
  require 'rack-static-if-present'
  use Rack::StaticCache, :urls => [
    '/images', '/javascripts', '/stylesheets', '/favicon.gif',
    '/robots.txt','/sitemap.xml'], :root => "public"
  use Rack::Rewrite do
    rewrite '/', '/_site/index.html'
    rewrite '/feed', '/_site/feed.xml'
    rewrite %r{^/(.*\.)(css|xml)}, '/_site/$1$2'
    rewrite %r{^/(?!email)(.*)}, '/_site/$1.html'
  end
  use Rack::StaticIfPresent, :urls => ["/"], :root => "public"
  require File.expand_path(File.join('.', 'app'))
  Aerial::App.set :environment, :production
  Aerial::App.set :root, root
  run Aerial::App
# else
#   require "aerial"
#   Aerial.new(root, "/config/config.yml")
#   Aerial::App.set :environment, ENV["RACK_ENV"] || :production
#   Aerial::App.set :port, 3000
#   Aerial::App.set :root, root
#   run Aerial::App
# end

