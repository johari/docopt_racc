module Docopt
  VERSION = '0.5.0'
end

require File.expand_path("../docopt/usage_block.rb", __FILE__)
require File.expand_path("../docopt/options_block.rb", __FILE__)

module Docopt

  class LanguageError < StandardError
  end

  class ARGVError < StandardError
  end

  class God
    def move(alt, cons, args, data)
      if args.length == 0
        data
      else
        alt.alt "expecting more arguments %s" % args.to_s
      end
    end

    def alt(message)
      raise ARGVError, message
    end
  end

  class << self
    def parse str
      parser = Docopt::UsageBlock::Parser.new(str)
      r = parser.parse()
      r
    end

    def docopt(usage, args=ARGV)
      pebble = parse usage
      god = God.new
      pebble.pass = god

      # $stderr.puts "pebble is %s (%s)" % [pebble.to_s, pebble.class]

      pebble.move(god, [], args, pebble.machine.data)
    end
  end

end
