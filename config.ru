#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "rack/jekyll"

run Rack::Jekyll.new

