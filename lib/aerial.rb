libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
AERIAL_ROOT = File.join(File.dirname(__FILE__), '..') unless defined? AERIAL_ROOT

# System requirements
require 'rubygems'
require 'grit'
require 'ftools'
require 'yaml'
require 'sinatra'
require 'rdiscount'
require 'aerial/base'

# Add caching to Sinatra
class Sinatra::Default
  include Cacheable
end

before do
  # kill trailing slashes for all requests except '/'
  request.env['PATH_INFO'].gsub!(/\/$/, '') if request.env['PATH_INFO'] != '/'
end

# Configuration
configure do
  set :views  => Aerial.config.theme_directory
  set :public => Aerial.config.public.directory
end

# Helpers
helpers do
  include Rack::Utils
  include Aerial::Helper
  alias_method :h, :escape_html
end

# Homepage
get '/' do
  cache haml(:index)
end

# Articles
get '/articles' do
  #Aerial::Git.commit_all(Aerial.config.blog.directory, "")
  @content_for_sidebar = partial(:sidebar)
  @articles = Aerial::Article.all
  cache haml(:articles)
end

get '/feed' do
  @articles = Aerial::Article.all
  haml :rss, :layout => false
end

# Sassy!
get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

# Single page
get '/:page' do
  @page = Aerial::Page.with_name(params[:page])
  cache haml(:page)
end

# Single article page
get '/:year/:month/:day/:article' do
  link = [params[:year], params[:month], params[:day], params[:article]].join("/")
  @content_for_sidebar = partial(:sidebar)
  @article = Aerial::Article.with_permalink("/#{link}")
  throw :halt, [404, not_found ] unless @article
  @page_title = @article.title
  cache haml(:post)
end

# Article tags
get '/tags/:tag' do
  @content_for_sidebar = partial(:sidebar)
  @articles = Aerial::Article.with_tag(params[:tag])
  cache haml(:articles)
end

# Article archives
get '/archives/:year/:month' do
  @content_for_sidebar = partial(:sidebar)
  @articles = Aerial::Article.with_date(params[:year], params[:month])
  cache haml(:articles)
end

# New comments
post '/article/:id/comments' do
  @content_for_sidebar = partial(:sidebar)
  @article = Aerial::Article.find(params[:id])
  throw :halt, [404, not_found ] unless @article
  @article.add_comment(Aerial::Comment.new(params))
  status 200
end

