require 'sinatra'

module Aerial
  class App < Sinatra::Base

    helpers do

      def page_title(title = nil)
        @content ||= {}
        @content[:title] = "Matt Sears"

        if params[:tag]
          @content[:title] << " | #{params[:tag]}"
        elsif params[:year] && !params[:day]
          @content[:title] << " | Archives #{params[:year]} "
        elsif @article
          @content[:title] << " | #{@article.title}"
        else
          @content[:title] << " | #{title}" if title
        end
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
      sass(:style)
    end
  end
end


