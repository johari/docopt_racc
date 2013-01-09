require "turn"
require "yaml"
require File.expand_path("../../lib/docopt.rb", __FILE__)

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  opts.on("-C", "--choose NUM", String, "Show Details") do |v|
    options[:choose] = v
  end

end.parse!

require "open3"
parser_test_path = File.expand_path("../../test/parser_test.rb", __FILE__)
suite_yaml_result = ""
Open3.popen3("turn #{parser_test_path} -M" +\
              (options[:choose] ? "-n #{options[:choose]}" : "")) do |i,o,e,t|
  suite_yaml_result = o.read
end

tests_path = File.expand_path("../../test/test_cases.yaml", __FILE__)
test_cases = YAML::load(File.open(tests_path).read)
YAML::load(suite_yaml_result).cases.each do |kase|
  kase.tests.sort_by { |x| x.name }.each do |test|
    test_name = test.name.gsub /^test_/, ''
    test_name = test_name.gsub /_run_.*$/, ''
    if test.pass? then
      puts "PASSED %s" % test_name
    elsif test.fail? then
      puts "FAILED %s" % test_name
    end
  end
end
