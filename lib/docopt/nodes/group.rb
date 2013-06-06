module Docopt
  module Nodes
    class Group < Node
      def move(alt, cons, args, data)
        @value.pass = @pass
        @value.move alt, cons, args, data
      end

      def alt reason
        @value.alt reason
      end

      def to_s
        '[":group", %s]' % @value.to_s
      end

      def pluralize
        @value.pluralize
      end

      def leaf_count
        @value.leaf_count
      end
    end
  end
end
