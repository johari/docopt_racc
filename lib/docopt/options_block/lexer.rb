module Docopt
  module OptionsBlock
    class Lexer
      require 'strscan'

      SHORT_OPT = /-[a-z]/i
      LONG_OPT = /--[a-z][a-z-]+/i
      DELIM = /(, *)| +/
      ARG = /<[a-z]+>|[A-Z]+/
      def initialize str
        @ss = StringScanner.new(str)
        @state = nil

        @ignore_rest_of_line_ret = nil
      end

      def next_token
        return nil if @ss.eos?

        case @state
        when nil
          @ss.skip_until(/^options:\n?/i)
          @state = :prev_or_new?
          next_token
        when :help_message
          help_line = @ss.scan(/.+/)
          if help_line =~ /\[default: *(.*)\]/i then
            [:t_default, $1]
          else
            if text = @ss.scan(/\n/) or @ss.eos? then
              @state = :prev_or_new?
              next_token
            else
              raise "me"
            end
          end
        when :new
          if text = @ss.scan(SHORT_OPT) then
            [:t_short_opt, text]
          elsif text = @ss.scan(LONG_OPT) then
            [:t_long_opt, text]
          elsif text = @ss.scan(/[[:blank:]]{2,}/) then
            @state = :help_message
            next_token
          elsif text = @ss.scan(/\=/) then
            [:t_eq, text]
          elsif text = @ss.scan(ARG) then
            [:t_arg, text]
          elsif text = @ss.scan(DELIM) then
            [:t_delim, text]
          end
        when :prev_or_new?
          @ss.skip(/[[:blank:]]+/)
          if (text = @ss.scan(SHORT_OPT)) or (text = @ss.scan(LONG_OPT)) then
            @state = :new
            @ss.unscan
            [:t_optline_begin, nil]
          elsif text = @ss.scan(/\n/) then
            @ss.terminate
            next_token
          else
            @state = :help_message
            # puts @ss.rest
            next_token
          end
        end
      end
    end
  end
end
