module Docopt
  module UsageBlock
    class Lexer
      require 'strscan'

      SHORT_OPT = /-[a-z]/i
      LONG_OPT = /--[a-z][a-z-]+/i
      DELIM = /(, *)| +/
      ARG = /<[a-z]+>|[A-Z]+/
      LDOTS = /\.\.\./

      def initialize str
        @ss = StringScanner.new(str)
        @state = nil
        @prog_name = nil

        @ignore_rest_of_line_ret = nil
      end

      def tokens
        res = []
        while (t = next_token) do
          res.push t
        end
        res
      end

      def next_token
        return nil if @ss.eos?

        case @state
        when nil
          @ss.skip_until(/^usage:\n?/i)
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
        when :new_car
          @ss.skip(/[[:blank:]]+/)
          if text = @ss.scan(/#{Regexp.quote @prog_name}/) then
            @state = :new_cdr
            [:t_prog_name, text]
          else
          end
        when :short_stack
          if text = @ss.scan(/[a-z]/) then
            [:t_short_opt, "-#{text}"]
          else
            @state = :new_cdr
            next_token
          end
        when :new_cdr
          @ss.skip(/[[:blank:]]+/)
          if text = @ss.scan(/\[options\]/) then
            [:t_options_shorthand, text]
          elsif text = @ss.scan(/\[/) then
            [text, text]
          elsif text = @ss.scan(/\]/) then
            [text, text]
          elsif text = @ss.scan(/\(/) then
            [text, text]
          elsif text = @ss.scan(/\)/) then
            [text, text]
          elsif text = @ss.scan(/-[a-z]/) then
            @state = :short_stack
            [:t_short_opt, text]
          elsif text = @ss.scan(/[a-z]+/) then
            [:t_cmd, text]
          elsif text = @ss.scan(LDOTS) then
            [:t_ldots, text]
          elsif text = @ss.scan(LONG_OPT) then
            [:t_long_opt, text]
          elsif text = @ss.scan(/\=/) then
            [text, text]
          elsif text = @ss.scan(ARG) then
            [:t_arg, text]
          elsif text = @ss.scan(/\|/) then
            [text, text]
          elsif text = @ss.scan(/\n/) then
            @state = :prev_or_new?
            next_token
          end
        when :prev_or_new?
          @ss.skip(/[[:blank:]]+/)
          if @prog_name.nil? then
            @prog_name = @ss.scan(/[\w\._-]+/)
            @ss.unscan
            return next_token
          end
          if (text = @ss.scan(/#{Regexp.quote @prog_name}/)) then
            @state = :new_car
            @ss.unscan
            [:t_synopses_begin, nil]
          elsif text = @ss.scan(/\n/) then
            @ss.terminate
            next_token
          else
            @state = :new_cdr
            next_token
          end
        end
      end
    end
  end
end
