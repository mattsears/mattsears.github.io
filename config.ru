#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "rack/jekyll"
require 'rack/contrib'
require 'rack-rewrite'
require 'rack-static-if-present'

use Rack::StaticCache, :urls => [
  '/images', '/javascripts', '/stylesheets', '/favicon.gif',
  '/robots.txt','/sitemap.xml'], :root => "_site"

use Rack::Rewrite do
  # Permanently move posts to the articles directory
  r301 %r{^/(\d{4})\/(\d+)\/(\d+)\/(.*)}, '/articles/$1/$2/$3/$4'
  r301 %r{^/articles/(\d{4})\/(\d{1})\/(\d{1})\/(.*)}, '/articles/$1/0$2/0$3/$4'

  rewrite '/feed', '/feed.xml'
  rewrite '/articles', '/articles.html'
  rewrite '/articles/', '/articles.html'
  rewrite '/about', '/'
  rewrite %r{^/articles/tags/(?!email)(.*)}, '/articles/tags/$1.html'
end
# use Rack::StaticIfPresent, :urls => ["/"], :root => "_site"
run Rack::Jekyll.new

