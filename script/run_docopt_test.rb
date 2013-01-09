require "turn"
require "yaml"
require "colored"
require "json"
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
    if options[:choose] and !test.name.match Regexp.new(options[:choose]) then
      next
    end
    puts "xxx".green.bold * 10 if options[:choose]
    matches = test.name.split "_run_"
    run_id = matches[1]
    test_name = matches[0].gsub /^test_/, ''
    status = test.pass? ? "PASSED".green.bold : "FAILED".red.bold
    test_banner = test_name.yellow
    test_banner += " run " + run_id.to_s.blue.bold if run_id
    puts "#{status} #{test_banner}"
    if options[:choose] and !test.pass? then
      usage = test_cases[test_name]["usage"]
      parser = Docopt::Parser.new
      puts "PEBBLE: %s" % parser.parse(usage)
      r = test_cases[test_name]["runs"][run_id.to_i]
      puts ("EXPECTED: " + r["expect"].to_json).magenta.bold
      puts ("MESSGAGE: ".red.bold) + test.message.magenta.bold
      puts "ARGS : ".red.bold + ("prog %s" % r["prog"]).to_s.blue.bold
      puts usage.yellow.bold
    end
  end
end
