module Docopt
  module Nodes
    class LongOption < Option
      def initialize(value, machine)
        super
        @opt_name = value
        @machine.type[value] ||= :singular_long_option
        if @machine.option_has_argument? @opt_name then
          @machine.data[value] = nil if not @machine.data.include? value
        else
          @machine.data[value] = false if not @machine.data.include? value
        end
      end

      def move(alt, cons, args, data)
        new_data = data.clone
        if @machine.option_has_argument? @opt_name then
          args.each_with_index do |argv_elem, index|
            if argv_elem =~ /(.*)=(.*)/ and
               @machine.uniq_prefix? $1, @opt_name
            then
              # long option has argument and the argument is provided
              # with `=' sign
              new_args = args[0...index]
              cdr = args[index+1..-1]
              new_args += cdr if cdr
              new_data = update_data new_data, $2
            elsif @machine.uniq_prefix? argv_elem, @opt_name then
              # consume next argv_elem as argument or fail if
              # there isn't any
              if index == args.length-1 then
                return alt.alt([:needs_argument, @opt_name])
              end

              val = args[index+1]
              # is it valid?
              unless @machine.is_valid_arg_for? @opt_name, val[0]
                return alt.alt([:needs_argument, @opt_name])
              end

              new_args = args[0...index]
              cdr = args[index+2..-1]
              new_args += cdr if cdr

              new_data = update_data new_data, val
            else
              #TODO: not a unique prefix
              next
            end
            return @pass.move(alt, cons + [@opt_name, val], new_args, new_data)
          end
        else
          args.each_with_index do |arg, index|
            if @machine.uniq_prefix? arg, @opt_name then
              new_args = args[0...index]
              cdr = args[(index+1)..-1]
              new_args += cdr if cdr
              new_data = update_data new_data, true
              return @pass.move(alt, cons+[@opt_name], new_args, new_data)
            end
          end
        end
        return alt.alt([:expected, @value])
      end

    end
  end
end
