module Docopt
  module Nodes
    class Optional < Node
      def move(alt, cons, args, data)
        super
        @history = [alt, cons, args, data]
        @value.pass = @pass
        @value.move(self, cons, args, data)
      end

      def alt(reason)
        super
        alt, cons, args, data = @history
        @pass.move(alt, cons, args, data)
      end

      def to_s
        '[":optional", %s]' % @value
      end

      def leaf_count
        @value.leaf_count
      end

      def pluralize
        @value.pluralize
      end
    end
  end
end
