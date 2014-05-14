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
          next unless argv_elem.start_with? "-"
          next if @machine.is_valid_arg? argv_elem

          argv_elem.chars.each_with_index do |char, elem_index|
            next if elem_index == 0 # char is the starting dash!

            cur_opt = "-#{char}"

            # if cur_opt needs argument and cur_opt is not our
            # desired option, we should skip this argv_elem because
            # the rest of argv_elem is the argument of cur_opt
            if @machine.option_has_argument? cur_opt and cur_opt == @opt_name then
              # we are dealing with a short_option with argument

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
                if not @machine.is_valid_arg_for?(@opt_name, val[0])
                  return alt.alt([:needs_argument, @opt_name])
                end

                new_args = args.take argv_index

                if argv_elem[0...elem_index] != "-"
                  new_args.push(argv_elem[0...elem_index])
                end

                rest_of_args = args.drop(argv_index+2) || []
                new_args += rest_of_args
                new_data = update_data new_data, val
              else
                # look for the argument in current argv_elem
                val = argv_elem[(elem_index+1)..-1]

                if not @machine.is_valid_arg_for?(@opt_name, val[0])
                  return alt.alt([:needs_argument, @opt_name])
                end

                new_args = args.take argv_index
                if argv_elem[0...elem_index] != "-" then
                  # there are some options before current option
                  # so keep them in argv
                  new_args.push(argv_elem[0...elem_index])
                else
                  # there isn't any other short_options before
                  # curruent option in this argv_elem
                  # so delete argv_elem from argv
                end
                new_args += args.drop argv_index+1

                new_data = update_data new_data, val
              end

              return @pass.move(alt, cons+[@opt_name, val], new_args, new_data)

            elsif cur_opt == @opt_name then

              # we are dealing with a boolean short option

              new_data = update_data new_data, true #FOUND IT!

              # remove the option from current argv_elem
              remainder = argv_elem.dup
              remainder[elem_index] = ""

              if remainder == "-" then
                # no other short options left in this argv_elem
                # remove argv_elem from args
                new_args = args.dup
                new_args.delete_at argv_index
              else
                new_args = args.dup
                new_args[argv_index] = remainder
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
