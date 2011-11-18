source 'http://rubygems.org'

gem 'grit'
gem 'haml'
gem 'rack'
gem 'rdiscount'
gem 'sinatra'
gem 'sass'

group :production do
  gem 'rack-contrib'
  gem 'rack-rewrite'
  gem 'rack-static-if-present'
end

group :development do
  gem 'aerial', :git => 'git://github.com/mattsears/aerial.git'
  #gem 'aerial', :path => '~/Workspace/aerial'
  gem 'heroku', '1.20.1'
  gem 'guard-livereload'
  gem 'guard-sass'
end
