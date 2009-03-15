require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib', 'aerial')

set :run         => false,
    :environment => ENV['RACK_ENV'].to_sym,
    :root        => File.dirname(__FILE__),
    :app_file    => File.join(File.dirname(__FILE__), 'lib', 'aerial.rb'),
    :cache_enabled => true

run Sinatra::Application
