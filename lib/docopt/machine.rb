require "docopt/nodes"

module Docopt
  class Machine
    attr_accessor :type, :data, :options, :all_options, :reasons,
      :untouched, :encountered_options

    def initialize(options={})
      @type = {}
      @data = {}
      @untouched = {}
      @options = options
      @options.each_pair do |opt, val|
        next if val.include? :alt
        @data[opt] = (val.include? :arg) ? nil : false
        @data[opt] = val[:default] if val.include? :default
        @untouched[opt] = true
      end
      @reasons = []
      @all_options = @options.keys
      @encountered_options = []
      @options_block_options = @all_options.dup
    end

    def option_has_argument? o
      if !@options.include? o
        false
      else
        if @options[o].include? :alt
          option_has_argument? @options[o][:alt]
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

    def is_valid_arg? val
      # a single dash is a valid argument
      return true if val == "-"

      # string starting with dash, other than "-"
      # is not a valid argument (it's a sequence of short options)
      return false if val[0] == "-"

      # other things are pretty fine
      return true
    end

    def is_valid_arg_for? option, val
      is_valid_arg? val
    end

    def get_options(pattern, of_where=:all_options)
      case of_where
      when :options_block
        target = @options_block_options - @encountered_options
      else
        target = @all_options
      end
      target.select { |x| x =~ pattern }.compact.uniq
    end

    def short_options(of_where=:all_options)
      get_options /^-[a-z]$/, of_where
    end

    def long_options(of_where=:all_options)
      get_options /^--/, of_where
    end

    def uniq_prefix? what, of_what
      r = long_options.select do |long|
        return true if what == of_what
        long.start_with? what
      end
      r.length == 1 and r[0] == of_what
    end

    def new_node(type, value)
      def classify what
        return what if what !~ /_/ && what =~ /[A-Z]+.*/
        what.split('_').map{|e| e.capitalize}.join
      end

      Nodes.const_get(classify type.to_s).new(value, self)
    end
  end
end
