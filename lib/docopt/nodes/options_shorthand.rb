module Docopt
  module Nodes
    class OptionsShorthand < EitherOptional
      def move(alt, cons, args, data)
        shorts = \
          @machine.short_options(:options_block).collect do |x|
            @machine.new_node(:short_option, x)
          end

        longs = \
          @machine.long_options(:options_block).collect do |x|
            @machine.new_node(:long_option, x)
          end

        old_pass = @new_node.pass
        @new_node = @machine.new_node(:either_optional, shorts+longs)
        @new_node.pass = old_pass
        super
      end

      def leaf_count
        {}
      end

      def to_s
        "[:options_shorthand]"
      end
    end
  end
end
