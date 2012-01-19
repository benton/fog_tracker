# Set up bundler
%w{rubygems bundler bundler/gem_tasks}.each {|dep| require dep}
Bundler.setup(:default, :test, :development)

# Load all tasks from 'lib/tasks'
Dir["#{File.dirname(__FILE__)}/lib/tasks/*.rake"].sort.each {|ext| load ext}

desc 'Default: run specs.'
task :default => :spec
