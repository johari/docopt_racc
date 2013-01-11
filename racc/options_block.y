class Parser
prechigh
  left '|'
preclow

rule
  target
    : options_block

  options_block
    : { result = [] }
    | option_lines

  option_lines
    : option_line { result = [val[0]] }
    | option_line option_lines { result = [val[0]] + val[1] }

  option_line
    : t_optline_begin option_line_car { result = val[1] }

  option_line_car
    : option_line_with_argument
    | option_line_with_argument t_default
      { if long = val[0][1] then
          long = long.dup
          long.update({:default => val[1]})
          result = [val[0][0], long]
        else
          short = val[0][0].dup
          short.update({:default => val[1]})
          result = [short, val[0][1]]
        end
      }
    | option_line_without_argument

  option_line_with_argument
    : short_opt t_delim long_opt_with_arg
        { result = [val[0], val[2]] }
    | short_opt_with_arg
        { result = [val[0], nil] }
    | long_opt_with_arg
        { result = [nil, val[0]] }
    | short_opt_with_arg t_delim long_opt_with_arg
        { result = [val[0], val[2]] }

  option_line_without_argument
    : short_opt { result = [val[0], nil] }
    | long_opt { result = [nil, val[0]] }
    | short_opt t_delim long_opt
        { result = [val[0], val[2]] }

  short_opt_with_arg
    : short_opt t_delim t_arg
        { short = val[0].dup
          short.update({:arg => val[2]})
          result = short
        }

  long_opt_with_arg
    : long_opt t_delim t_arg
      { long = val[0].dup
        long.update({:arg => val[2]})
        result = long
      }
    | long_opt t_eq t_arg
      { long = val[0].dup
        long.update({:eq => true, :arg => val[2]})
        result = long
      }

  short_opt
    : t_short_opt { result = {:name => val[0]} }

  long_opt
    : t_long_opt { result = {:name => val[0]} }

end

---- header

require File.expand_path("../lexer.rb", __FILE__)

module Docopt
module OptionsBlock


---- inner

  def initialize str
    @str = str + "\n"
  end

  def parse
    @lexer = Lexer.new(@str)
    foo = do_parse
    options = {}
    foo.each do |(short, long)|
      [short, long].each do |qux|
        if qux then
          quux = qux.dup
          quux.delete :name
          options[qux[:name]] = quux
        end
      end
      if short and long then
        options[short[:name]].update({:alt => long[:name]})
        options[short[:name]].delete :arg if long[:arg]
      end
    end
    options
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
