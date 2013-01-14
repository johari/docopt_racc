module Docopt
  module Constants
    SHORT_OPT = /-[a-z]/i
    LONG_OPT = /--[a-z][a-z-]+/i
    DELIM = /(, *)| +/
    VAR = /<[a-z\/]+>|[A-Z]+/
    ARG = /[a-z]+/
    LDOTS = /\.\.\./
  end
end
