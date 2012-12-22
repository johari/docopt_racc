require "shellwords"
task :default => :test

task :build => [:lexer, :parser]


require "rake/testtask"
Rake::TestTask.new(:test => :build) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/parser.rb'
  test.verbose = true
  if ENV["RUBYOPTS"] then
    test.ruby_opts = Shellwords.shellwords(ENV["RUBYOPTS"])
  end
end

task :parser do
  sh "racc racc/docopt.y -o lib/docopt/parser/docopt.rb"
end

task :lexer do
  %w(usage options).each do |what|
    sh "ragel -R racc/lexer/#{what}.rb.rl -o lib/docopt/parser/#{what}_lexer.rb"
  end
end

task :dot do
  sh "ragel -pV racc/lexer/options.rb.rl | dot -Tpng > /tmp/options.png"
  sh "ragel -pV racc/lexer/usage.rb.rl | dot -Tpng > /tmp/usage.png"
end
