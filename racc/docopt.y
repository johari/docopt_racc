class Parser
prechigh
  left '|'
preclow

rule
  target
    : docopt

  docopt
    : synopsis { result = val[0] }

  synopsis
    : synopses t_endl
        { result = val[0] }
    | synopses t_endl synopsis
        { result = @machine.new_node(:either, [val[0], val[2]]) }

  synopses
    : t_prog_name mutex
        { result = val[1] }
    | t_prog_name
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
        { result = @machine.new_node(:short_option, [val[0], val[1]]) }
    | t_long_opt
        { result = @machine.new_node(:long_option, val[0]) }
    | t_long_opt_arged '=' t_var
        { result = @machine.new_node(:long_option, [val[0], "=", val[2]]) }
    | t_long_opt_arged t_var
        { result = @machine.new_node(:long_option, [val[0], val[1]]) }
    | t_options_shorthand
        { result = @machine.new_node(:options_shorthand, \
            @machine.short_options.collect do |x|
              @machine.new_node(:short_option, x)
            end)
        }


  arg_group
    : '(' mutex ')'
        { result = val[1] }
    | '[' mutex ']'
        { result = @machine.new_node(:optional, val[1])
          if val[1].kind_of? Docopt::Machine::Nodes::ShortOption then
            result = @machine.new_node(:options_shorthand, [val[1]])
          elsif val[1].kind_of? Docopt::Machine::Nodes::Cons \
            and val[1].cons_of? Docopt::Machine::Nodes::ShortOption
            then
            result = @machine.new_node(:options_shorthand, val[1].cons)
          end
        }

end

---- header

require File.expand_path("../../machine.rb", __FILE__)
require File.expand_path("../../options_block.rb", __FILE__)

module Docopt
---- inner

  def initialize()
  end

  def parse(str)
    str += "\n"
    options = Docopt::parse_options(str)
    @machine = Docopt::Machine.new(options)
    @q = tokenizer.tokenize()
    @consumed = []
    # $stderr.puts @q.to_s
    do_parse
  end

  def next_token
    res = @q.shift
    @consumed.push res
    # puts res.to_s
    res
  end

  def on_error(error_token_id, error_value, value_stack)
    raise Docopt::LanguageError, "error near %s, \"%s\"" % \
      [(@consumed[-5..-1] || []).map { |x| x[1] }.to_s, error_value]
  end

---- footer
end
