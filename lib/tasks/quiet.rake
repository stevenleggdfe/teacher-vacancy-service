if defined? RSpec
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end
end
