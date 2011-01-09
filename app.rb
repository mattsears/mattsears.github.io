require 'sinatra'

module Aerial
  class App < Sinatra::Base
    # Sassy!
    get '/style.css' do
      scss(:style)
    end
  end
end


