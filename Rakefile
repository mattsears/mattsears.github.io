desc "Launch preview environment."
task :server do
  system "middleman server"
end

desc "Build site"
task :build => [:clean] do |task, args|
  system "middleman build"
end

task :clean do
  # system "rm -rf build"
end

def current_branch
  `git status`.split("\n").first.split(" ").last
end

desc "Deploy application to Production Heroku app"
task :deploy do
  if current_branch.nil? || current_branch == '' || current_branch != "master"
    raise "You must be on the master branch to deploy to production!"
    exit
  end
  puts "\n"
  puts " ############################################################################"
  puts " #\n # Are you REALLY sure you want to deploy to production?"
  puts " #\n # Enter y/N + enter to continue\n #"
  puts " ############################################################################"
  puts "\n"
  proceed = STDIN.gets[0..0] rescue nil
  exit unless proceed == 'y' || proceed == 'Y'

  puts ">> Pushing to heroku"
  # system "heroku maintenance:on -a mattsears"
  system "git push heroku master"
  # system "heroku maintenance:off -a mattsears"
end
