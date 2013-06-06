module Docopt
  module Nodes
    class Var < Node
      def initialize(value, machine)
        super
        @machine.type[@value] ||= :variable
        @machine.data[@value] ||= nil
      end

      def move(alt, cons, args, data)
        super
        start = 0
        args.each do |arg|
          (start +=1; next) if arg[0] == "-" and arg != "-"
          break
        end
        if args[start] then
          new_data = data.dup
          case @machine.type[@value]
          when :list
            new_data[@value] += [args[start]]
          when :variable
            new_data[@value] = args[start]
          end
          @pass.move(alt, cons + [args[start]], args[0...start] + args[(start+1)..-1], new_data)
        else
          alt.alt [:expected, @value]
        end
      end

      def pluralize
        @machine.type[@value] = :list
        @machine.data[@value] = []
      end

      def leaf_count
        {self => 1}
      end

      def to_s
        '[":var", %s]' % @value
      end
    end
  end
end
