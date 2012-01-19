require 'bundler/setup'
require 'rake/testtask'
require 'stuff-classifier'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = StuffClassifier::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "stuff-classifier #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :test

