%%{
  machine docopt_options_lexer;

  t_short_opt = "-" alpha;
  t_short_opt_stack = "-" alpha{1,};
  t_long_opt = ("--" (alpha | "-")+);
  t_option = t_short_opt | t_long_opt;
  t_var = "<" (any - space)+ ">" | upper+;

  main :=
    any*
    (/options:/i | "\n") space* "-" @{ fhold; fcall options_block; }
    any*
    ;

  options_block := |*
    t_short_opt => { curopt[0] = conv(ts, te) };
    t_long_opt => { curopt[1] = conv(ts, te) };
    t_var { curopt[2] = :arged };
    [\t ]{2,} when { curopt != [] } => { fcall opt_block_ignore; };
    "\n" when { curopt != [] } => { optype[curopt[0..1]] = curopt[2..3] || [nil, nil]; curopt = [] };
    "\n" when { curopt == [] } => { fret; };
    space|/[=,]/;
  *|;

  opt_block_ignore := |*
    "[default:" space* alnum+ "]" { curopt[3] = conv(ts, te).gsub /\[default: *(.*)\]/, '\1' };
    "\n" => { optype[curopt[0..1]] = curopt[2..3]  || [nil, nil]; curopt = []; fret; };
    any;
  *|;

}%%

module Docopt

  class Tokenizer
    attr_accessor :optype

    def parse_options
      %%write data;

      data = @data
      eof = data.length
      stack = []
      curopt = []
      optype = {}

      %%write init;
      %%write exec;

      optype
    end
  end
end
