module Docopt
  module Nodes
    class Arg < Node
      def initialize(value, machine)
        super
        @machine.type[@value] ||= :singular
        @machine.data[@value] ||= false
      end

      def move(alt, cons, args, data)
        super
        start = 0
        args.each do |arg|
          (start +=1; next) if arg[0] == "-" and arg != "-"
          break
        end
        if args[start] == @value then
          new_data = data.clone
          case @machine.type[@value]
          when :plural
            new_data[args[start]] += 1
          when :singular
            new_data[args[start]] = true
          end
          @pass.move(alt, cons + [args[start]], args[0...start] + args[(start+1)..-1], new_data)
        else
          alt.alt [:expected, @value]
        end
      end

      def pluralize
        @machine.type[@value] = :plural
        @machine.data[@value] = 0
      end

      def leaf_count
        {self => 1}
      end

      def to_s
        '"%s"' % @value
      end

    end
  end
end
