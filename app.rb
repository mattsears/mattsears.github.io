require 'sinatra'

module Aerial
  class App < Sinatra::Base
    # Sassy!
    get '/style.css' do
      sass(:style)
    end
  end
end


