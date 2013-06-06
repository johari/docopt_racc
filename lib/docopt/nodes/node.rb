module Docopt
  module Nodes
    class Node
      attr_accessor :pass, :machine, :value

      def initialize(value, machine)
        @value = value
        @machine = machine
      end

      def move(alt, cons, args, data)
      end

      def alt(reason)
        @machine.reasons.push reason
      end

      def to_s
        @value.to_s
      end

      def eql?(other)
        self.to_s == other.to_s
      end

      def hash
        self.to_s.hash
      end

    end
  end
end
