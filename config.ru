#!/usr/bin/env ruby
require "rubygems"

env  = ENV['RACK_ENV'].to_sym
root = File.expand_path(File.dirname(__FILE__))
#root = File.dirname(__FILE__)

if env == :production
  require 'rack/contrib'
  require 'rack-rewrite'

  use Rack::StaticCache, :urls => ['/images','/stylesheets','/favicon.ico'], :root => "public"
  #use Rack::ETag
  use Rack::Rewrite do
    rewrite '/', '/site/index.html'
    rewrite %r{^(.*)\.css}, '/site/$1.css'
    rewrite %r{^(.*)}, '/site/$1.html'
  end
else

  require "aerial"
  #require File.join(File.dirname('/Users/matt/Workspace/aerial/'), "aerial", "lib", "aerial.rb")

  # Load configuration and initialize Aerial
  Aerial.new(root, "/config/config.yml")
  Aerial::App.set :environment, ENV["RACK_ENV"] || :development
  Aerial::App.set :root, root
  # You probably don't want to edit anything below
  disable :run
  run Aerial::App
end

