require 'sinatra'

module Aerial
  class App < Sinatra::Base

    helpers do
      def page_title(title = nil)
        @content ||= {}
        @content[:title] = "Matt Sears"
        @content[:title] << " | #{title}" if title
      end

      def body_class(name)
        @content ||= {}
        @content[:body_class] = name.to_s
      end

      def yield_content(key)
        @content && @content[key]
      end

      def body_id(name)
        @content ||= {}
        @content[:body_id] = name.to_s
      end
    end

    # Sassy!
    get '/style.css' do
      scss(:style)
    end
  end
end


