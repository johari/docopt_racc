require "minitest/autorun"
require "yaml"
require "shellwords"
require File.expand_path("../../lib/docopt.rb", __FILE__)


class TestParser < MiniTest::Unit::TestCase
end

TestParser.instance_eval do
  test_cases = File.open \
    File.expand_path("../test_cases.yaml", __FILE__)
  test_cases = YAML::load(test_cases.read)
  test_cases.each_pair do |id, test_case|
    test_case["runs"] ||= []

    test_case["runs"].each_with_index do |run, index|
      self.send :define_method, \
        ("test_%s_run_%d" % [id, index]).to_sym do
          args = Shellwords.shellwords(run["prog"])
          case run["expect"]
          when "user-error"
            assert_raises Docopt::ARGVError do
              Docopt::docopt(test_case["usage"], args)
            end
          else
            assert_equal run["expect"], Docopt::docopt(test_case["usage"], args)
          end
      end
    end

    self.send :define_method, ("test_%s" % id).to_sym do
      if test_case.include? "tokens" then
        tokenizer = Docopt::Tokenizer.new(test_case["usage"])
        tokens = tokenizer.tokenize()
        tokens.map! { |x| x[1] }
        assert_equal test_case["tokens"], tokens
      end
      if test_case["should"] == "fail" then
        assert_raises Docopt::LanguageError do
          parser = Docopt::Parser.new
          pebble = parser.parse(test_case["usage"])
        end
      elsif test_case.include? "pebble"
        parser = Docopt::Parser.new
        pebble = parser.parse(test_case["usage"])
        assert_equal test_case["pebble"], YAML::load(pebble.to_s)
      end
    end
  end
end
