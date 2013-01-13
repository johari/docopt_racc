require "minitest/autorun"
require "test_helper"
require "docopt/machine"

class Catcher
  def initialize &asserter
    @asserter = asserter
  end

  def move alt, cons, args, data
    @asserter.call(alt, cons, args, data)
  end

  def alt reason
    raise reason
  end
end

module Docopt
  class TestShortOptionPebble < MiniTest::Unit::TestCase
    def test_short_option_without_argument
      machine = Machine.new({"-f" => {}})
      pebble = Machine::Nodes::ShortOption.new("-f", machine)
      catcher = Catcher.new do |alt, cons, args, data|
        assert_equal ["-o"], args
        assert_equal({"-f" => true}, data)
        assert_equal ["-f"], cons
      end
      pebble.pass = catcher
      pebble.move(catcher, [], ["-of"], {})
    end

    def test_short_option_with_argument
      machine = Machine.new({"-f" => {:alt => "--foo"}, "--foo" => {:arg => "BAR"}})
      pebble = Machine::Nodes::ShortOption.new("-f", machine)

      catcher = Catcher.new do |alt, cons, args, data|
        assert_equal ["-o"], args
        assert_equal({"--foo" => "oo"}, data)
        assert_equal ["-f", "oo"], cons
      end
      pebble.pass = catcher
      pebble.move(catcher, [], ["-ofoo"], {})

      # catcher = Catcher.new do |alt, cons, args, data|
      #   assert_equal ["-o"], args
      #   assert_equal({"-f" => true}, data)
      #   assert_equal ["-f"], cons
      # end
      # pebble.pass = catcher
      # pebble.move(catcher, [], ["-of"], {})

    end
  end
end
