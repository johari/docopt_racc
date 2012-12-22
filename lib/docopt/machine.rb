class String
  def classify
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end

module Docopt
  class Machine
    attr_accessor :type, :data, :options

    def initialize(options={})
      @type = {}
      @data = {}
      @options = options
    end

    def short_options
      @options.keys.map { |x| x[0] }.compact
    end

    def new_node(type, value)
      Nodes.const_get(type.to_s.classify).new(value, self)
    end

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
        end

        def to_s
          @value.to_s
        end
      end

      class Null < Node
        def move(alt, cons, args, data)
          @pass.move(alt, cons, args, data)
        end
      end

      class Either < Node
        def move(alt, cons, args, data)
          super
          @history = [alt, cons, args, data]
          @value[0].pass = @pass
          @value[0].move(self, cons, args, data)
        end

        def alt(reason)
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
      end

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
              self.alt "matched kleene star of epsilon"
            else
              @value.move(self, cons, args, data)
            end
          else
            @read_already = true
            @value.move(alt, cons, args, data)
          end
        end

        def alt(reason)
          alt, cons, args, data = @greed.pop
          @value.pass = @pass
          if @greed.length > 0 then
            alt = self
          end
          @value.move(alt, cons, args, data)
        end

        def pluralize
          # duh!
        end

        def to_s
          '[":oom", %s]' % @value.to_s
        end
      end

      class Optional < Node
        def move(alt, cons, args, data)
          super
          @history = [alt, cons, args, data]
          @value.pass = @pass
          @value.move(self, cons, args, data)
        end

        def alt(reason)
          alt, cons, args, data = @history
          @pass.move(alt, cons, args, data)
        end

        def to_s
          '[":optional", %s]' % @value
        end

        def pluralize
          @value.pluralize
        end
      end

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

        def pluralize
          @value.each { |v| v.pluralize }
        end

        def to_s
          "[%s]" % cons.join(", ")
        end

      end

      class Option < Node
        def pluralize
          t = @machine.type[@value].to_s
          @machine.type[@value] = t.sub("singular", "plural").to_sym
          if t =~ /arged/ then
            @machine.data[@value] = []
          else
            @machine.data[@value] = 0
          end
        end

        def to_s
          foo = {"ShortOption" => :short_opt, "LongOption" => :long_opt}
          '[":%s", %s]' % [foo[self.class.name.split("::")[-1]].to_s, @value]
        end
      end

      class LongOption < Option
        def initialize(value, machine)
          super
          if value.kind_of? String then
            @machine.type[value] ||= :singular_long_option
            @machine.data[value] ||= false
          elsif value.kind_of? Array then
            @machine.type[value] ||= :singular_arged_long_option
            @machine.data[value] ||= nil
          end
        end

        def move(alt, cons, args, data)
          new_data = data.clone
          found = false
          consed = @value
          new_args = args.collect do |arg|
            if not found and arg == @value then
              found = true
              new_data[consed] = true
              nil
            else
              arg
            end
          end.compact
          if found then
            @pass.move(alt, cons + [consed], new_args, new_data)
          else
            alt.alt("expected %s" % @value)
          end
        end

      end

      class ShortOption < Option
        def initialize(value, machine)
          super
          if value.kind_of? String then
            @machine.type[value] ||= :singular_short_option
            @machine.data[value] ||= false
          elsif value.kind_of? Array then
            @machine.type[value] ||= :singular_arged_short_option
            @machine.data[value] ||= nil
          end
          @opt_name = @value[1..-1]
        end

        def move(alt, cons, args, data)
          new_data = data.clone
          consed = ""
          found = false
          new_args = args.collect do |arg|
            if not found and arg =~ /(-[a-z]*)#{@opt_name}([a-z]*)/ then
              found = true
              consed = "-#{@opt_name}"
              new_data[consed] = true
              res = [$1,$2].join
              case res
              when "-"
                nil
              else
                res
              end
            else
              arg
            end
          end.compact
          if found then
            @pass.move(alt, cons + [consed], new_args, new_data)
          else
            alt.alt("expected %s" % @value)
          end
        end
      end

      class OptionsShorthand < Node
        def initialize(value, machine)
          super
          vals = value.map do |short_opt|
            @machine.new_node(:optional, short_opt)
          end

          case vals.length
          when 0
            @new_node = @machine.new_node(:null, nil)
          when 1
            @new_node = vals[0]
          else
            @new_node = vals.inject do |memo, cons|
              @machine.new_node(:cons, [memo, cons])
            end
          end
        end

        def pass=(what)
          @new_node.pass = what
        end

        def move(alt, cons, args, data)
          @new_node.move(alt, cons, args, data)
        end

        def alt(reason)
          @new_node.alt reason
        end

        def to_s
          @new_node.to_s
        end

      end

      class Var < Node
        def initialize(value, machine)
          super
          @machine.type[@value] ||= :variable
          @machine.data[@value] ||= nil
        end

        def move(alt, cons, args, data)
          super
          if args.length > 0 then
            new_data = data.clone
            case @machine.type[@value]
            when :list
              new_data[@value] += [args[0]]
            when :variable
              new_data[@value] = args[0]
            end
            @pass.move(alt, cons + [args[0]], args[1..-1], new_data)
          else
            alt.alt "expected variable %s %s" % [@value, [cons, args].to_s]
          end
        end

        def pluralize
          @machine.type[@value] = :list
          @machine.data[@value] = []
        end

        def to_s
          '[":arg", %s]' % @value
        end
      end

      class Arg < Node
        def initialize(value, machine)
          super
          @machine.type[@value] ||= :singular
          @machine.data[@value] ||= false
        end

        def move(alt, cons, args, data)
          super
          if args[0] == @value then
            new_data = data.clone
            case @machine.type[@value]
            when :plural
              new_data[args[0]] += 1
            when :singular
              new_data[args[0]] = true
            end
            @pass.move(alt, cons + [args[0]], args[1..-1], new_data)
          else
            alt.alt "expected %s" % @value
          end
        end

        def pluralize
          @machine.type[@value] = :plural
          @machine.data[@value] = 0
        end

        def to_s
          '"%s"' % @value
        end

      end
    end

  end
end
