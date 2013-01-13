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

    def is_arged? o
      if !@options.include? o
        false
      else
        if @options[o].include? :alt
          is_arged? @options[o][:alt]
        else
          @options[o].include? :arg
        end
      end
    end

    def arg_of o
      if !@options.include? o
        nil
      else
        if @options[o].include? :alt
          arg_of @options[o][:alt]
        else
          @options[o][:arg]
        end
      end
    end

    def short_options
      @options.keys.select { |x| x =~ /^-[a-z]$/ }.compact
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
          if @machine.is_arged? @opt_name then
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
          @opt_name = @value
          @machine.type[value] ||= :singular_short_option
          if @machine.is_arged? @opt_name then
            @machine.data[value] ||= nil
          else
            @machine.data[value] ||= false
          end
        end

        def name_in_data
          opt = @machine.options[@opt_name]
          if opt and opt.include? :alt then
            opt[:alt]
          else
            @opt_name
          end
        end

        def move(alt, cons, args, data)
          new_data = data.clone
          found = false
          args.each_with_index do |arg, args_index|
            if arg[0] == "-" then
              arg[0..-1].each_char.each_with_index do |short, index|
                break if found
                next if index == 0
                cur_opt = "-#{short}"
                if @machine.is_arged? cur_opt then
                  if cur_opt == @opt_name then
                    if @machine.is_arged? cur_opt then
                      if index == arg.length-1 then
                        if args_index == args.length-1 then
                          return alt.alt("%s need argument" % @opt_name)
                        else
                          val = args[args_index+1]
                          if val[0] == "-" then
                            return alt.alt("%s need argument" % @opt_name)
                          end
                          new_args = args[0...args_index]
                          new_args = [arg[0...index]] if arg[0...index] != "-"
                          aaron = args[(args_index+2)..-1]
                          new_args += aaron if aaron
                          new_data[name_in_data] = val
                        end
                      else
                        val = arg[(index+1)..-1]
                        if val[0]== "-" then
                          return alt.alt("%s needs argument" % @opt_name)
                        end
                        if arg[0..(index-1)] == "-" then
                          new_args = args[0...args_index] + args[(args_index+1)..-1]
                        else
                          new_args = args[0...args_index] + [arg[0...index]] + args[(args_index+1)..-1]
                        end
                        new_data[name_in_data] = val
                      end
                      return @pass.move(alt, cons+[@opt_name, val], new_args, new_data)
                    end
                  else
                    break
                  end
                else
                  if cur_opt == @opt_name then
                    new_data[name_in_data] = true
                    new_arg = arg[0...index] + arg[(index+1)..-1]
                    if new_arg == "-" then
                      new_args = args[0...args_index] + args[(args_index+1)..-1]
                    else
                      new_args = args[0...args_index]\
                               + [new_arg]\
                               + args[(args_index+1)..-1]
                    end
                    return @pass.move(alt, cons + [@opt_name], new_args, new_data)
                  end
                end
              end
            else
              next
            end
          end
          alt.alt("expected %s" % @opt_name)
        end

        def to_s
          if @machine.is_arged? @opt_name then
            '[":short_opt", "%s", "%s"]' % [@opt_name, @machine.arg_of(@opt_name)]
          else
            super
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
          start = 0
          args.each do |arg|
            (start +=1; next) if arg[0] == "-"
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
