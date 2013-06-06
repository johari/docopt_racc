require "shellwords"

module Docopt
  module Nodes
    class Option < Node
      def initialize value, machine
        super
        @machine.all_options.push value
        @machine.encountered_options.push value
      end

      def pluralize
        t = @machine.type[@value].to_s
        if @machine.type[@value].to_s =~ /singular/ then
          @machine.type[@value] = t.sub("singular", "plural").to_sym
          if @machine.option_has_argument? @opt_name then
            @machine.data[@value] = Shellwords.shellwords(@machine.data[@value] || "")
          else
            @machine.data[@value] = 0
          end
        end
      end

      def leaf_count
        {self => 1}
      end

      def to_s
        foo = {"ShortOption" => :short_opt, "LongOption" => :long_opt}
        '[":%s", %s]' % [foo[self.class.name.split("::")[-1]].to_s, @value]
      end

      def name_in_data
        opt = @machine.options[@opt_name]
        if opt and opt.include? :alt then
          opt[:alt]
        else
          @opt_name
        end
      end

      def update_data what, with_what
        has_argument = @machine.option_has_argument? @opt_name
        singular = @machine.type[@opt_name].to_s =~ /singular/

        if has_argument
          new_data = singular ? with_what : [with_what]
        else
          new_data = singular ? true : 1
        end

        if singular
          what[name_in_data] = new_data
        else
          if @machine.untouched[name_in_data]
            what[name_in_data] = new_data
            @machine.untouched[name_in_data] = false
          else
            what[name_in_data] += new_data
          end
        end

        what
      end
    end
  end
end
