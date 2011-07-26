require 'rubygems'

task :deploy do
  system "bundle exec aerial build --config=config/config.yml"
  puts "\n commit static files to the repo...."
  system "git add public/_site/*"
  system "git commit -m 'Commit updates static files to repo before deploy'"
  puts "\n Pushing latest site to heroku..."
  system "git push heroku master"
  puts "\n>> compeleted"
end
