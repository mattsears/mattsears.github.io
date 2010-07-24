#!/usr/bin/env ruby
# -*- coding: undecided -*-
require "rubygems"

env  = ENV['RACK_ENV'].to_sym
root = File.expand_path(File.dirname(__FILE__))

if env == :production
  require 'rack/contrib'
  require 'rack-rewrite'
  use Rack::StaticCache, :urls => ['/images', '/javascripts', '/favicon.ico'], :root => "public"
  use Rack::Rewrite do
    rewrite '/', '/site/index.html'
    rewrite %r{^/(.*\.)(css)}, '/site/$1$2'
    rewrite %r{^/(.*)}, '/site/$1.html'
  end
  run Rack::Directory.new('public')
else
  require "aerial"
  #require File.join(File.dirname('/Users/matt/Workspace/aerial/'), "aerial", "lib", "aerial.rb")
  Aerial::App.set :environment, ENV["RACK_ENV"] || :development
  Aerial::App.set :root, root
  Aerial.new(root, "/config/config.yml") # Load configuration and initialize Aerial
  disable :run
  run Aerial::App
end

