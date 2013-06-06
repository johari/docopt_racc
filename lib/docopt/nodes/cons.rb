module Docopt
  module Nodes
    class Cons < Node
      def move(alt, cons, args, data)
        super
        (@value + [@pass]).each_cons(2) do |car, cadr|
          car.pass = cadr
        end
        @value[0].move(alt, cons, args, data)
      end

      def cons
        if @value[1].kind_of? Cons then
          [@value[0]] + @value[1].cons
        else
          @value
        end
      end

      def cons_of?(what)
        @value.all? do |x|
          if x.kind_of? Cons and what != Cons then
            x.cons_of? what
          else
            x.kind_of? what
          end
        end
      end

      def leaf_count
        r = {}
        @value.each do |c|
          r.merge! c.leaf_count do |k, o, n|
            # puts r.to_s
            o+n
          end
        end
        r
      end

      def pluralize
        @value.each { |v| v.pluralize }
      end

      def to_s
        "[%s]" % cons.join(", ")
      end

    end
  end
end
