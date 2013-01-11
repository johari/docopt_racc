require File.expand_path("../parser/usage_lexer.rb", __FILE__)

module Docopt
  class Tokenizer
    def conv(ts, te)
      @data[ts...te].pack("c*")
    end

    attr_reader :optype

    def initialize(data)
      @q = []
      @data = data.unpack("c*")
      @optype = Docopt::parse_options data
    end

    def is_arged?(option, type)
      not @optype.select do |key, value|
        key[type == :short ? 0 : 1] == option and value[0] == :arged
      end.empty?
    end
  end
end
