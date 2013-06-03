module Docopt
  VERSION = '0.5.0'
end

require File.expand_path("../docopt/usage_block.rb", __FILE__)
require File.expand_path("../docopt/options_block.rb", __FILE__)

module Docopt

  class LanguageError < StandardError
  end

  class ARGVError < SystemExit
    def initialize(message, silent=false)
      puts message unless silent
      super(message)
    end
  end

  class God
    def initialize(pebble, usage, silent=false)
      @pebble = pebble
      @usage = usage
      @silent = silent
    end

    def move(alt, cons, args, data)
      if args.length == 0
        data
      else
        alt.alt "expecting more arguments"
      end
    end

    def alt(message)
      @pebble.machine.reasons.each do |(t, v)|
        error = ARGVError.new("#{v} requires argument", @silent)
        raise error if t == :needs_argument
      end

      e = ARGVError.new(@usage, @silent)
      raise e
    end
  end

  class << self
    def parse str
      parser = Docopt::UsageBlock::Parser.new(str)
      r = parser.parse()
      r
    end

    def docopt(usage, args, silent=false)
      pebble = parse usage
      god = God.new(pebble, usage, silent)
      pebble.pass = god

      # $stderr.puts "pebble is %s (%s)" % [pebble.to_s, pebble.class]

      pebble.move(god, [], args, pebble.machine.data)
    end
  end

end

def docopt(*params, &block)
  args = ARGV
  if params[0].is_a? Array
    args = params[0]
  elsif params[0].is_a? String
    usage = params[0]
    args ||= params[1]
  end

  file = caller(1)[0].split(/:(?=\d|in )/, 3)[0]

  begin
    io = ::IO.read(file)
    app, data = io.gsub("\r\n", "\n").split(/^__END__$\n/, 2)
  rescue Errno::ENOENT
    app, data = nil
  end

  usage ||= data

  options = Docopt::docopt usage, args
  if block_given? then
    block.call(options)
  else
    options
  end
end
