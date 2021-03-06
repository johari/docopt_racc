module Docopt
  module UsageBlock
    class Lexer
      require 'strscan'
      require File.expand_path('../../constants.rb', __FILE__)
      include Docopt::Constants

      def initialize str, machine
        @ss = StringScanner.new(str)
        @state = nil
        @prog_name = nil
        @machine = machine
        @ignore_rest_of_line_ret = nil
      end

      def tokens
        res = []
        res.push t while (t = next_token)
        res
      end

      def next_token
        return nil if @ss.eos?

        case @state
        when nil
          @ss.skip_until(USAGE_BLOCK)
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
        when :emit_unstandard_arg
          @state = :new_cdr
          if text = @ss.scan(/[a-z]+/)
            [:t_var, text]
          else
            next_token
          end
        when :short_stack
          if text = @ss.scan(/[a-z]/) then
            opt = "-#{text}"
            if @machine.option_has_argument? opt then
              @state = :emit_unstandard_arg
              [:t_short_opt_arged, opt]
            else
              [:t_short_opt, opt]
            end
          else
            @state = :new_cdr
            next_token
          end
        when :new_cdr
          @ss.skip(/[[:blank:]]+/)
          if text = @ss.scan(/\[options\]/) then
            [:t_options_shorthand, text]
          elsif text = @ss.scan(/[\[\]\(\)]/) then
            [text, text]
          elsif text = @ss.scan(/-[a-z]/) then
            @state = :short_stack
            @ss.unscan
            @ss.scan /-/
            next_token
          elsif text = @ss.scan(LDOTS) then
            [:t_ldots, text]
          elsif text = @ss.scan(LONG_OPT) then
            if @machine.option_has_argument? text then
              [:t_long_opt_arged, text]
            else
              [:t_long_opt, text]
            end
          elsif text = @ss.scan(/\=/) then
            [text, text]
          elsif text = @ss.scan(ARG) then
            [:t_arg, text]
          elsif text = @ss.scan(VAR) then
            [:t_var, text]
          elsif text = @ss.scan(/\|/) then
            [text, text]
          elsif text = @ss.scan(/\n +/) then
            @state = :prev_or_new?
            next_token
          elsif text = @ss.scan(/\n/) then
            @ss.terminate
            next_token
          end
        when :prev_or_new?
          @ss.skip(/[[:blank:]]+/)
          if @prog_name.nil? then
            @prog_name = @ss.scan(PROG_NAME)
            if @prog_name then
              @ss.unscan
              return next_token
            else
              return nil
            end
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
