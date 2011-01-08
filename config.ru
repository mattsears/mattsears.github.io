#!/usr/bin/env ruby
# -*- coding: undecided -*-
require "rubygems"

env  = ENV['RACK_ENV'].to_sym
root = File.dirname(__FILE__)

if env == :production
  require 'rack/contrib'
  require 'rack-rewrite'
  use Rack::StaticCache, :urls => ['/images', '/javascripts', '/favicon.ico', '/site'], :root => "public"
  use Rack::Rewrite do
    rewrite '/', '/site/index.html'
    rewrite '/feed', '/site/feed.xml'
    rewrite %r{^/(.*\.)(css|xml)}, '/site/$1$2'
    rewrite %r{^/(.*)}, '/site/$1.html'
  end
  run Rack::Directory.new('public')
else
  require "aerial"
  Aerial.new(root, "/config/config.yml")
  Aerial::App.set :environment, ENV["RACK_ENV"] || :production
  Aerial::App.set :port, 3000
  Aerial::App.set :root, root
  run Aerial::App
end

