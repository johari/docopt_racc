module Docopt
  module Nodes
    class Null < Node
      def move(alt, cons, args, data)
        @pass.move(alt, cons, args, data)
      end

      def leaf_count
        {}
      end
    end
  end
end
