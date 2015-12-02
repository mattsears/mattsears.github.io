desc "Launch preview environment."
task :server do
  system "middleman server"
end

desc "Build site"
task :build => [] do |task, args|
  system "middleman build"
end

require 'statistrano'

deployment = define_deployment "basic" do
  hostname   '107.170.125.62'
  user       'deployer' # optional if remote is setup in .ssh/config
  remote_dir '/home/deployer/apps/mattsears/current/public'
  local_dir  'build'
  build_task 'build' # optional if nothing needs to be built
  rsync_flags '-aqz --delete-after' # optional, flags for rsync
  check_git  false # optional, set to false if git shouldn't be checked
end

deployment.register_tasks
