require 'rubygems'
require 'rack/contrib'
require 'rack-rewrite'
require 'rack-static-if-present'

# require 'middleman/rack'
# run Middleman.server

module Rack
  class TryStatic
    def initialize(app, options)
      @app = app
      @try = ['', *options.delete(:try)]
      @static = ::Rack::Static.new(lambda { [404, {}, []] }, options)
    end

    def call(env)
      orig_path = env['PATH_INFO']
      found = nil
      @try.each do |path|
        resp = @static.call(env.merge!({'PATH_INFO' => orig_path + path}))
        break if 404 != resp[0] && found = resp
      end
      found or @app.call(env.merge!('PATH_INFO' => orig_path))
    end
  end
end

use Rack::TryStatic,
    :root => "build",
    :urls => %w[/],
    :try => ['.html', 'index.html', '/index.html']

use Rack::StaticCache, :urls => [
  '/images', '/javascripts', '/stylesheets', '/favicon.gif',
  '/robots.txt'
], :root => "build"

use Rack::Rewrite do
  # Permanently move posts to the articles directory
  r301 %r{^/(\d{4})\/(\d+)\/(\d+)\/(.*)}, '/articles/$1/$2/$3/$4'
  r301 %r{^/articles/(\d{4})\/(\d{1})\/(\d{1})\/(.*)}, '/articles/$1/0$2/0$3/$4'
  rewrite '/feed', '/feed.xml'
  rewrite '/articles', '/articles.html'
  rewrite '/articles/', '/articles.html'
  rewrite '/about', '/'
end

# Run your own Rack app here or use this one to serve 404 messages:

run lambda{ |env|
  not_found_page = File.expand_path("../build/404.html", __FILE__)
  if File.exist?(not_found_page)
    [ 404, { 'Content-Type'  => 'text/html'}, [File.read(not_found_page)] ]
  else
    [ 404, { 'Content-Type'  => 'text/html' }, ['404 - page not found'] ]
  end
}
