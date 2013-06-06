module Docopt
  module Nodes
    class ShortOption < Option
      def initialize(value, machine)
        super
        @opt_name = @value
        @machine.type[value] ||= :singular_short_option
        if not (@machine.options[@opt_name] \
                and @machine.options[@opt_name].include? :alt) then
          if @machine.option_has_argument? @opt_name then
            @machine.data[value] = nil if not @machine.data.include? value
          else
            @machine.data[value] = false if not @machine.data.include? value
          end
        end
      end

      def move(alt, cons, args, data)
        new_data = data.clone
        args.each_with_index do |argv_elem, argv_index|
          # short option is in an argv_elem starting with dash
          next unless argv_elem[0] == "-"

          argv_elem.each_char.each_with_index do |char, elem_index|
            next if elem_index == 0 # char is the starting dash!

            cur_opt = "-#{char}"

            if @machine.option_has_argument? cur_opt then
              unless cur_opt == @opt_name
                # won't find desired short option (@opt_name) in
                # this argv_elem
                # rest of the argv_elem would be the argument of
                # cur_opt, because cur_opt has_argument
                # so skip checking other characters in current argv_elem
                # and scan the next one
                break
              end

              if elem_index == argv_elem.length-1 then
                # at the last character of argv_elem
                # look for the argument in next argv_elem

                # fail if there's no further argv_elem
                if argv_index == args.length-1
                  return alt.alt([:needs_argument, @opt_name])
                end

                # argument is supposed to be the next element in argv
                val = args[argv_index+1]
                # we should check if it's a valid value for option argument
                unless @machine.is_valid_arg_for? @opt_name, val[0]
                  return alt.alt([:needs_argument, @opt_name])
                end

                new_args = args[0...argv_index]

                #BUG: should be +=
                if argv_elem[0...elem_index] != "-"
                  new_args = [argv_elem[0...elem_index]]
                end

                rest_of_args = args[(argv_index+2)..-1]
                new_args += rest_of_args if rest_of_args #might be nil
                new_data = update_data new_data, val
              else
                # look for the argument in current argv_elem
                val = argv_elem[(elem_index+1)..-1]

                unless @machine.is_valid_arg_for? @opt_name, val[0]
                  return alt.alt([:needs_argument, @opt_name])
                end

                new_args = args[0...argv_index]
                unless argv_elem[0..(elem_index-1)] == "-" then
                  # there are some options before current option
                  # so keep them in argv
                  new_args += [argv_elem[0...elem_index]]
                else
                  # there isn't any options before current option
                  # so pop the argv_elem from argv
                end
                new_args += args[(argv_index+1)..-1]

                new_data = update_data new_data, val
              end
              return @pass.move(alt, cons+[@opt_name, val], new_args, new_data)
            elsif cur_opt == @opt_name then
              new_data = update_data new_data, true #FOUND IT!

              remainder = argv_elem[0...elem_index] + argv_elem[(elem_index+1)..-1]
              if remainder == "-" then
                new_args = args[0...argv_index] + args[(argv_index+1)..-1]
              else
                new_args = args[0...argv_index]\
                         + [remainder]\
                         + args[(argv_index+1)..-1]
              end

              return @pass.move(alt, cons + [@opt_name], new_args, new_data)
            end
          end
        end
        alt.alt([:expected, @opt_name])
      end

      def to_s
        if @machine.option_has_argument? @opt_name then
          '[":short_opt", "%s", "%s"]' % [@opt_name, @machine.arg_of(@opt_name)]
        else
          super
        end
      end
    end
  end
end
