# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "sandrbox"
  gem.homepage = "http://github.com/Veraticus/Sandrbox"
  gem.license = "MIT"
  gem.summary = 'A sanitizing sandbox for executing Ruby code'
  gem.description = 'A sandbox for that tries to change all Ruby code executed to be safe and non-destructive, both to the filesystem and the currently running process'
  gem.email = "josh@joshsymonds.com"
  gem.authors = ["Josh Symonds"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

desc "Open an irb session preloaded with this library"
task :cons do
  sh "irb -rubygems -I lib -r sandrbox.rb"
end

task :default => :spec