require "test_helper"
require "docopt/usage_block/lexer"
require "docopt/machine"

module Docopt
  module UsageBlock
    class TestUsageBlockLexer < MiniTest::Unit::TestCase
      def tokens_for str
        lexer = Lexer.new str, Docopt::Machine.new
        lexer.tokens
      end

      def test_raw_naval_fate
        expected = [[:t_synopses_begin, nil],
                    [:t_prog_name, "naval_fate.py"],
                      [:t_arg, "ship"], [:t_arg, "new"],
                      [:t_var, "<name>"], [:t_ldots, "..."],
                    [:t_synopses_begin, nil],
                      [:t_prog_name, "naval_fate.py"],
                      [:t_arg, "ship"], [:t_var, "<name>"],
                      [:t_arg, "move"], [:t_var, "<x>"], [:t_var, "<y>"],
                      ["[", "["],
                        [:t_long_opt, "--speed"],
                        ["=", "="], [:t_var, "<kn>"],
                      ["]", "]"],
                    [:t_synopses_begin, nil],
                      [:t_prog_name, "naval_fate.py"],
                      [:t_arg, "ship"],
                      [:t_arg, "shoot"], [:t_var, "<x>"], [:t_var, "<y>"],
                    [:t_synopses_begin, nil],
                      [:t_prog_name, "naval_fate.py"],
                      [:t_arg, "mine"],
                      ["(", "("],
                        [:t_arg, "set"], ["|", "|"], [:t_arg, "remove"],
                      [")", ")"], [:t_var, "<x>"], [:t_var, "<y>"],
                      ["[", "["],
                        [:t_long_opt, "--moored"],
                        ["|", "|"], [:t_long_opt, "--drifting"],
                      ["]", "]"],
                    [:t_synopses_begin, nil],
                      [:t_prog_name, "naval_fate.py"],
                        [:t_short_opt, "-h"],
                        ["|", "|"], [:t_long_opt, "--help"],
                    [:t_synopses_begin, nil],
                      [:t_prog_name, "naval_fate.py"],
                      [:t_long_opt, "--version"]]

        assert_equal expected, tokens_for(load_raw "naval_fate")
      end

      def test_raw_options
        expected = [[:t_synopses_begin, nil],
                    [:t_prog_name, "options_example.py"],
                      ["[", "["],
                        [:t_short_opt, "-h"],
                        [:t_short_opt, "-v"],
                        [:t_short_opt, "-q"],
                        [:t_short_opt, "-r"],
                        [:t_short_opt, "-f"],
                        [:t_var, "NAME"],
                      ["]", "]"],
                      ["[", "["],
                        [:t_long_opt, "--exclude"],
                        ["=", "="], [:t_var, "PATTERNS"],
                      ["]", "]"],
                      ["[", "["],
                        [:t_long_opt, "--select"],
                        ["=", "="], [:t_var, "ERRORS"],
                        ["|", "|"], [:t_long_opt, "--ignore"],
                        ["=", "="], [:t_var, "ERRORS"],
                      ["]", "]"],
                      ["[", "["],
                        [:t_long_opt, "--show-source"],
                      ["]", "]"],
                      ["[", "["],
                        [:t_long_opt, "--statistics"],
                      ["]", "]"],
                      ["[", "["],
                        [:t_long_opt, "--count"],
                      ["]", "]"],
                      ["[", "["],
                        [:t_long_opt, "--benchmark"],
                      ["]", "]"],
                      [:t_var, "PATH"], [:t_ldots, "..."],
                    [:t_synopses_begin, nil],
                    [:t_prog_name, "options_example.py"],
                      ["(", "("],
                        [:t_long_opt, "--doctest"], ["|", "|"],
                        [:t_long_opt, "--testsuite"],
                        ["=", "="], [:t_var, "DIR"],
                      [")", ")"],
                    [:t_synopses_begin, nil],
                    [:t_prog_name, "options_example.py"],
                      [:t_long_opt, "--version"]]
          assert_equal expected, tokens_for(load_raw "options_example")
      end
    end
  end
end
