class Parser
prechigh
  left '|'
preclow

rule
  target
    : docopt
      { val[0].leaf_count.each do |leaf, count|
          leaf.pluralize if count > 1
        end
      }

  docopt
    : synopsis { result = val[0] }

  synopsis
    : synopses
        { result = val[0] }
    | synopses synopsis
        { result = @machine.new_node(:either, [val[0], val[1]]) }

  synopses
    : t_synopses_begin t_prog_name mutex
        { result = val[2] }
    | t_synopses_begin t_prog_name
        { result = @machine.new_node(:null, nil) }

  mutex
    : args
    | args '|' mutex
        { result = @machine.new_node(:either, [val[0], val[2]]) }

  args
    : arg
        { result = val[0] }
    | arg args
        { result = @machine.new_node(:cons, [val[0], val[1]]) }

  arg
    : arg_repeatable
    | arg_repeatable t_ldots
        { result = @machine.new_node(:one_or_more, val[0]) }

  t_long_option_with_arg_argument
    : t_var
    | t_arg

  arg_repeatable
    : t_arg
        { result = @machine.new_node(:arg, val[0]) }
    | t_var
        { result = @machine.new_node(:var, val[0]) }
    | arg_group
        { result = val[0] }
    | t_short_opt
        { result = @machine.new_node(:short_option, val[0]) }
    | t_short_opt_arged t_var
        { result = @machine.new_node(:short_option, val[0]) }
    | t_long_opt
        { result = @machine.new_node(:long_option, val[0]) }
    | t_long_opt_arged '=' t_long_option_with_arg_argument
        { result = @machine.new_node(:long_option, val[0]) }
    | t_long_opt '=' t_long_option_with_arg_argument
        { @machine.options[val[0]] ||= {}
          @machine.options[val[0]].update({:arg => val[2]})
          result = @machine.new_node(:long_option, val[0]) }
    | t_long_opt_arged t_var
        { result = @machine.new_node(:long_option, val[0]) }
    | t_options_shorthand
        { result = @machine.new_node(:options_shorthand, []) }


  arg_group
    : '(' mutex ')'
        { result = @machine.new_node(:group, val[1]) }
    | '[' mutex ']'
        { #HACK
          result = @machine.new_node(:optional, val[1])
          # if val[1].kind_of? Docopt::Machine::Nodes::ShortOption then
          #   result = @machine.new_node(:either_optional, [val[1]])
          # els
          if val[1].kind_of? Docopt::Machine::Nodes::Cons \
            then
            result = @machine.new_node(:either_optional, val[1].cons)
          end
        }

end

---- header

require File.expand_path("../../machine.rb", __FILE__)
require File.expand_path("../../options_block.rb", __FILE__)
require File.expand_path("../lexer.rb", __FILE__)

module Docopt
module UsageBlock
---- inner

  def initialize str
    @str = str
  end

  def parse
    @seen = {}
    @str += "\n"
    options = Docopt::parse_options(@str)
    @machine = Docopt::Machine.new(options)
    @lexer = Lexer.new(@str, @machine)
    do_parse
  end

  def next_token
    r = @lexer.next_token
    # puts r.to_s
    r
  end

  def on_error(error_token_id, error_value, value_stack)
    raise Docopt::LanguageError, "error \"%s\"" % \
      [error_value]
  end

---- footer
end
end
