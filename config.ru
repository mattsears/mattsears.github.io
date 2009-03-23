require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib', 'aerial')

root_dir = File.dirname(__FILE__)
env = ENV['RACK_ENV'].to_sym

set :environment   => env,
    :root          => root_dir,
    :app_file      => File.join(root_dir, 'lib', 'aerial.rb'),
    :cache_enabled => env == :production ? true : false

disable :run
run Sinatra::Application
