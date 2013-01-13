require "minitest/autorun"
require "test_helper"
require "docopt/usage_block/lexer"

module Docopt
  module UsageBlock
    class TestUsageBlockLexer < MiniTest::Unit::TestCase
      def tokens_for str
        lexer = Lexer.new str
        lexer.tokens
      end

      def test_raw_naval_fate
        expected = [[:t_synopses_begin, nil],
                    [:t_prog_name, "naval_fate.py"],
                      [:t_cmd, "ship"], [:t_cmd, "new"],
                      [:t_arg, "<name>"], [:t_ldots, "..."],
                    [:t_synopses_begin, nil],
                      [:t_prog_name, "naval_fate.py"],
                      [:t_cmd, "ship"], [:t_arg, "<name>"],
                      [:t_cmd, "move"], [:t_arg, "<x>"], [:t_arg, "<y>"],
                      ["[", "["],
                        [:t_long_opt, "--speed"],
                        [:t_eq, "="], [:t_arg, "<kn>"],
                      ["]", "]"],
                    [:t_synopses_begin, nil],
                      [:t_prog_name, "naval_fate.py"],
                      [:t_cmd, "ship"],
                      [:t_cmd, "shoot"], [:t_arg, "<x>"], [:t_arg, "<y>"],
                    [:t_synopses_begin, nil],
                      [:t_prog_name, "naval_fate.py"],
                      [:t_cmd, "mine"],
                      ["(", "("],
                        [:t_cmd, "set"], [:t_or, "|"], [:t_cmd, "remove"],
                      [")", ")"], [:t_arg, "<x>"], [:t_arg, "<y>"],
                      ["[", "["],
                        [:t_long_opt, "--moored"],
                        [:t_or, "|"], [:t_long_opt, "--drifting"],
                      ["]", "]"],
                    [:t_synopses_begin, nil],
                      [:t_prog_name, "naval_fate.py"],
                        [:t_short_opt, "-h"],
                        [:t_or, "|"], [:t_long_opt, "--help"],
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
                        [:t_arg, "NAME"],
                      ["]", "]"],
                      ["[", "["],
                        [:t_long_opt, "--exclude"],
                        [:t_eq, "="], [:t_arg, "PATTERNS"],
                      ["]", "]"],
                      ["[", "["],
                        [:t_long_opt, "--select"],
                        [:t_eq, "="], [:t_arg, "ERRORS"],
                        [:t_or, "|"], [:t_long_opt, "--ignore"],
                        [:t_eq, "="], [:t_arg, "ERRORS"],
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
                      [:t_arg, "PATH"], [:t_ldots, "..."],
                    [:t_synopses_begin, nil],
                    [:t_prog_name, "options_example.py"],
                      ["(", "("],
                        [:t_long_opt, "--doctest"], [:t_or, "|"],
                        [:t_long_opt, "--testsuite"],
                        [:t_eq, "="], [:t_arg, "DIR"],
                      [")", ")"],
                    [:t_synopses_begin, nil],
                    [:t_prog_name, "options_example.py"],
                      [:t_long_opt, "--version"]]
          assert_equal expected, tokens_for(load_raw "options_example")
      end
    end
  end
end
