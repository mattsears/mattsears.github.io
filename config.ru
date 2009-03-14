require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib', 'aerial')

set :run         => false,
    :env         => ENV['RACK_ENV'].to_sym,
    :root        => File.dirname(__FILE__),
    :app_file    => File.join(File.dirname(__FILE__), 'lib', 'aerial.rb')

run Sinatra::Application
