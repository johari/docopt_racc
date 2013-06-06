module Docopt
  module Nodes
    class EitherOptional < Node
      def initialize(value, machine)
        super(value, machine)
        vals = value.map do |x|
          @machine.new_node(:optional, x)
        end

        case vals.length
        when 0
          @new_node = @machine.new_node(:null, nil)
        when 1
          @new_node = vals[0]
        else
          @new_node = vals.inject do |memo, cons|
            @machine.new_node(:cons, [memo, cons])
          end
        end
      end

      def pass=(what)
        @new_node.pass = what
      end

      def move(alt, cons, args, data)
        @new_node.move(alt, cons, args, data)
      end

      def alt(reason)
        @new_node.alt reason
      end

      def to_s
        @new_node.to_s
      end

      def pluralize
        @new_node.pluralize
      end

      def leaf_count
        @new_node.leaf_count
      end
    end
  end
end
