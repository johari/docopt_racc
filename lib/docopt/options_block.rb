require File.expand_path("../options_block/parser.rb", __FILE__)

module Docopt
  class << self
    def parse_options str
      parser = Docopt::OptionsBlock::Parser.new(str)
      parser.parse()
    end
  end
end
