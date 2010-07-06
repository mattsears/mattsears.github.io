# $:.unshift(File.dirname(__FILE__) + '/../../../lib')

require 'rubygems'
require 'spec/version'
require 'spec/rake/spectask'
require 'cucumber/rake/task'

# Rspec setup
desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['lib/spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs with rcov"
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList['lib/spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--exclude', "lib/spec.rb,lib/spec/runner.rb,spec\/spec,bin\/spec,examples,\/gems,\/Library\/Ruby,\.autotest,#{ENV['GEM_HOME']}"]
  end
end

# Cucumber setup
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty"
end

# Vlad setup
begin
  require "vlad"
  Vlad.load(:app => nil, :scm => "git")
  rescue LoadError
  # do nothing
end
