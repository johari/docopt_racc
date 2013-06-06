module Docopt
  module Nodes
    class Either < Node
      def move(alt, cons, args, data)
        super
        @history = [alt, cons, args, data]
        @value[0].pass = @pass
        @value[0].move(self, cons, args, data)
      end

      def alt(reason)
        super
        alt, cons, args, data = @history
        @value[1].pass = @pass
        @value[1].move(alt, cons, args, data)
      end

      def cons
        if @value[1].kind_of? Either then
          [@value[0]] + @value[1].cons
        else
          @value
        end
      end

      def to_s
        '[":either", %s]' % cons.join(", ")
      end

      def pluralize
        @value.each { |v| v.pluralize }
      end

      def leaf_count
        @value.reduce({}) do |memo, val|
          memo.merge val.leaf_count do |key, old_val, new_val|
            [old_val, new_val].max
          end
        end
      end
    end
  end
end
