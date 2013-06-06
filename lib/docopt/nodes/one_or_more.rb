module Docopt
  module Nodes
    class OneOrMore < Node

      def initialize(value, machine)
        super
        @value.pluralize
      end

      def move(alt, cons, args, data)
        super
        @value.pass = self
        @greed ||= []
        @greed.push [alt, cons, args, data]
        if @read_already then
          if @greed.length > 1 and @greed[-1] == @greed[-2] then
            self.alt [:error, "matched kleene star of epsilon"]
          else
            @value.move(self, cons, args, data)
          end
        else
          @read_already = true
          @value.move(alt, cons, args, data)
        end
      end

      def alt(reason)
        super
        alt, cons, args, data = @greed.pop
        @value.pass = @pass
        if @greed.length > 0 then
          alt = self
        end
        @value.move(alt, cons, args, data)
      end

      def leaf_count
        lc = @value.leaf_count
        lc.merge lc do |k, ov, nv|
          2
        end
      end

      def pluralize
        @value.pluralize
      end

      def to_s
        '[":oom", %s]' % @value.to_s
      end
    end
  end
end
