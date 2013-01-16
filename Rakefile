require "shellwords"
task :default => :test

task :build => :parser


require "rake/testtask"
Rake::TestTask.new(:test => :build) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/**/*_test.rb']
  test.verbose = true
  if ENV["RUBYOPTS"] then
    test.ruby_opts = Shellwords.shellwords(ENV["RUBYOPTS"])
  end
end

task :parser do
  sh "racc racc/docopt.y -o lib/docopt/parser/docopt.rb"
  sh "racc racc/options_block.y -o lib/docopt/options_block/parser.rb"
end
