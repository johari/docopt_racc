%%{
  machine docopt_usage_lexer;

  aldash = (alpha | "-" | ".");
  t_short_opt = "-" alpha;
  t_short_opt_stack = "-" alpha{1,};
  t_long_opt = ("--" aldash+);
  t_option = t_short_opt | t_long_opt;
  t_var = "<" (any - space)+ ">" | upper+;
  t_arg = lower aldash*;

  main := |*
    /usage:/i space* => { seen_usage = true; };
    [a-z._]+ when { seen_usage == true } =>
      { prog_name = conv(ts, te);
        emit(:t_prog_name, prog_name);
        fcall synopsis;
      };
    any;
  *|;

  synopsis := |*
    "\n\n" => { emit(:t_endl, "\n"); fbreak; };
    "\n" (space - "\n")* (any - space)+ =>
      { matches = conv(ts, te).match(/([\n\s]*)(.*)/)
        read = matches[2]
        if read == prog_name then
          emit(:t_endl, "\n")
          emit(:t_prog_name, read)
        else
          puts "bar"
          p -= read.length
        end
      };
    "\n" => { emit(:t_endl, "\n"); fbreak; };
    t_arg "..." { emit(:t_arg, conv(ts, te-3)); emit(:t_ldots, "..."); };
    t_arg => { emit(:t_arg, conv(ts, te)) };
    "[options]" { emit(:t_options_shorthand, conv(ts, te)) };
    t_var "..." { emit(:t_var, conv(ts, te-3)); emit(:t_ldots, "..."); };
    "..." => { emit(:t_ldots, conv(ts, te)) };
    t_var { emit(:t_var, conv(ts, te)) };
    /[\[\]\(\)\|=]/ => { emit(data[ts..ts].pack("c*"), conv(ts, te)) };
    t_long_opt =>
      { opt_name = conv(ts, te)
        emit(is_arged?(opt_name, :long) ? :t_long_opt_arged : :t_long_opt, conv(ts, te))
      };
    t_short_opt_stack =>
      { short_opts = conv(ts, te)
        short_opts[1..-1].each_char do |opt_name|
          opt_name = "-" + opt_name
          emit(is_arged?(opt_name, :short) ? :t_short_opt_arged : :t_short_opt,
              opt_name)
        end
      };
    space => { };
  *|;

}%%

module Docopt

  class Tokenizer

    def emit(token_name, conv)
      res = [token_name, conv]
      @q.push res
    end

    def tokenize
      %%write data;

      data = @data
      eof = data.length
      stack = []
      cur_opt = []
      seen_usage = false

      %%write init;
      %%write exec;

      @q.push [false, '$end']
      @q
    end
  end
end
