desc "Launch preview environment."
task :server do
  system("for i in ./_layouts/*.haml; do [ -e $i ] && haml $i ${i%.haml}.html; done & compass watch & jekyll --auto --pygments --server")
end

desc "Build site"
task :build => [:clean] do |task, args|
  system "jekyll"
end

task :clean do
  system "rm -rf _site"
end

