require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--color', '--format progress', '-r ./spec/spec_helper.rb']
end
