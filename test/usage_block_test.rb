require "minitest/autorun"
require "yaml"
require "shellwords"
require "test_helper"
require "docopt"


class TestParser < MiniTest::Unit::TestCase
end

TestParser.instance_eval do
  TEST_CASES.each_pair do |id, test_case|
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
        lexer = Docopt::UsageBlock::Lexer.new(test_case["usage"])
        assert_equal test_case["tokens"],\
          lexer.tokens.map! { |x| x[1] }.keep_if { |x| x }
      end
      if test_case["should"] == "fail" then
        assert_raises Docopt::LanguageError do
          pebble = Docopt::parse(test_case["usage"])
        end
      elsif test_case.include? "pebble"
        pebble = Docopt::parse(test_case["usage"])
        assert_equal test_case["pebble"], YAML::load(pebble.to_s)
      end
    end
  end
end
