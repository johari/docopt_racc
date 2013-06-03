require "shellwords"
require "rake/testtask"

task :default => :test
task :build => :parser

Rake::TestTask.new(:test => :build) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/**/*_test.rb']
  test.verbose = false
  if ENV["RUBYOPTS"] then
    test.ruby_opts = Shellwords.shellwords(ENV["RUBYOPTS"])
  end
end

task :parser do
  sh "racc racc/usage_block.y -o lib/docopt/usage_block/parser.rb"
  sh "racc racc/options_block.y -o lib/docopt/options_block/parser.rb"
end

task :agnostic do
  sh "cat test/raw/testcases.docopt |
      python script/parse_agnostic_tests.py |
      ruby -ryaml -e 'puts YAML::load($stdin).to_yaml' > test/raw/agnostic.yaml"
end
