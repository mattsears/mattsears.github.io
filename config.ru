require 'rubygems'
require 'bundler'
Bundler.require(:default, :production)

require 'rack-jekyll'
run Rack::Jekyll.new
