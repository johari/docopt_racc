require "minitest/autorun"
require "test_helper"
require "docopt/options_block/lexer"

module Docopt
  module OptionsBlock
    class TestOptionsBlockLexer < MiniTest::Unit::TestCase
      def tokens_for str
        lexer = Lexer.new str
        res = []
        while (t = lexer.next_token) do
          res.push t
        end
        res
      end

      def test_empty
        assert_equal [], tokens_for("")
      end

      def test_raw_any_options
        expected = [[:t_optline_begin, nil],
                      [:t_short_opt, "-h"], [:t_delim, " "], [:t_long_opt, "--help"],
                    [:t_optline_begin, nil], [:t_long_opt, "--version"],
                    [:t_optline_begin, nil],
                      [:t_short_opt, "-n"], [:t_delim, ", "],
                      [:t_long_opt, "--number"],
                      [:t_delim, " "], [:t_arg, "N"],
                    [:t_optline_begin, nil],
                      [:t_short_opt, "-t"], [:t_delim, ", "],
                      [:t_long_opt, "--timeout"],
                      [:t_delim, " "], [:t_arg, "TIMEOUT"],
                    [:t_optline_begin, nil], [:t_long_opt, "--apply"],
                    [:t_optline_begin, nil], [:t_short_opt, "-q"]]
        assert_equal expected, tokens_for(load_raw "any_options_example")
      end

      def test_raw_options
        expected = [[:t_optline_begin, nil],
                      [:t_short_opt, "-h"], [:t_delim, " "], [:t_long_opt, "--help"],
                    [:t_optline_begin, nil], [:t_long_opt, "--version"],
                    [:t_optline_begin, nil],
                      [:t_short_opt, "-v"], [:t_delim, " "],
                      [:t_long_opt, "--verbose"],
                    [:t_optline_begin, nil],
                      [:t_short_opt, "-q"], [:t_delim, " "], [:t_long_opt, "--quiet"],
                    [:t_optline_begin, nil],
                      [:t_short_opt, "-r"], [:t_delim, " "],
                      [:t_long_opt, "--repeat"],
                    [:t_optline_begin, nil],
                      [:t_long_opt, "--exclude"], [:t_eq, "="], [:t_arg, "PATTERNS"],
                      [:t_default, ".svn,CVS,.bzr,.hg,.git"],
                    [:t_optline_begin, nil],
                      [:t_short_opt, "-f"], [:t_delim, " "],
                      [:t_arg, "NAME"], [:t_delim, " "],
                      [:t_long_opt, "--file"], [:t_eq, "="], [:t_arg, "NAME"],
                      [:t_default, "*.py"],
                    [:t_optline_begin, nil],
                      [:t_long_opt, "--select"], [:t_eq, "="], [:t_arg, "ERRORS"],
                    [:t_optline_begin, nil],
                      [:t_long_opt, "--ignore"], [:t_eq, "="], [:t_arg, "ERRORS"],
                    [:t_optline_begin, nil], [:t_long_opt, "--show-source"],
                    [:t_optline_begin, nil], [:t_long_opt, "--statistics"],
                    [:t_optline_begin, nil], [:t_long_opt, "--count"],
                    [:t_optline_begin, nil], [:t_long_opt, "--benchmark"],
                    [:t_optline_begin, nil],
                      [:t_long_opt, "--testsuite"], [:t_eq, "="], [:t_arg, "DIR"],
                    [:t_optline_begin, nil], [:t_long_opt, "--doctest"]]
          assert_equal expected, tokens_for(load_raw "options_example")
      end
    end
  end
end
