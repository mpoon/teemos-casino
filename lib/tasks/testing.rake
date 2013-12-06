# Fix to make rake test pick up new folders
# http://stackoverflow.com/questions/15256938/raketest-not-running-custom-tests-in-subdirectory
namespace :test do
  Rake::TestTask.new(workers: "test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'test/workers/*_test.rb'
  end

  Rake::Task[:test].enhance do
    Rake::Task["test:workers"].invoke
  end
end

