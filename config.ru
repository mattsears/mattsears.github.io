require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib', 'aerial')

root_dir = File.dirname(__FILE__)

set :environment   => ENV['RACK_ENV'].to_sym,
    :root          => root_dir,
    :app_file      => File.join(root_dir, 'lib', 'aerial.rb'),
    :cache_enabled => false

disable :run
run Sinatra::Application
