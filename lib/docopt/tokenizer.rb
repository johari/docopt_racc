require File.expand_path("../parser/usage_lexer.rb", __FILE__)
require File.expand_path("../parser/options_lexer.rb", __FILE__)

module Docopt
  class Tokenizer
    def conv(ts, te)
      @data[ts...te].pack("c*")
    end

    def initialize(data)
      @q = []
      @data = data.unpack("c*")
      @optype = parse_options
    end

    def is_arged?(option, type)
      not @optype.select do |key, value|
        key[type == :short ? 0 : 1] == option and value[0] == :arged
      end.empty?
    end
  end
end
