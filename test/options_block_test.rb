require "minitest/autorun"
require "test_helper"
require "docopt"

class TestOptionsBlock < MiniTest::Unit::TestCase
  def test_raw_any_options
    d = Docopt.parse_options(load_raw "any_options_example")
    expected = {"-h" => {:alt => "--help"},
                "--help" => {},
                "--version" => {},
                "-n" => {:alt => "--number"},
                "--number" => {:arg => "N"},
                "-t" => {:alt => "--timeout"},
                "--timeout" => {:arg => "TIMEOUT"},
                "--apply" => {},
                "-q" => {}}
    assert_equal expected, d
  end

  def test_raw_options
    d = Docopt.parse_options(load_raw "options_example")
    expected = {"-h" => {:alt => "--help"},
                "--help" => {},
                "--version" => {},
                "-v" => {:alt => "--verbose"},
                "--verbose" => {},
                "-q" => {:alt => "--quiet"},
                "--quiet" => {},
                "-r" => {:alt => "--repeat"},
                "--repeat" => {},
                "--exclude" => {:arg => "PATTERNS", :eq => true,
                                :default => ".svn,CVS,.bzr,.hg,.git"},
                "-f" => {:alt => "--file"},
                "--file" => {:arg => "NAME", :default => "*.py", :eq => true},
                "--select" => {:arg => "ERRORS", :eq => true},
                "--ignore" => {:arg => "ERRORS", :eq => true},
                "--show-source" => {},
                "--statistics" => {},
                "--count" => {},
                "--benchmark" => {},
                "--testsuite" => {:arg => "DIR", :eq => true},
                "--doctest" => {}}
    require "yaml"
    assert_equal expected, d
  end

end
